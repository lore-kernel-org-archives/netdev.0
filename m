From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: brcmfmac build failure with gcc < 4.3 due to __UNIQUE_ID() clash
Date: Sat, 16 Jan 2016 14:03:25 +0200
Message-ID: <87fuxx7muq.fsf@kamboji.qca.qualcomm.com>
References: <CAMuHMdWYrQtWUwPJ0i95WphvW-Q6pj900xYgbjwkizj6tp26cg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Hante Meuleman <meuleman@broadcom.com>,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	brcm80211-dev-list@broadcom.com,
	"linux-kernel\@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAMuHMdWYrQtWUwPJ0i95WphvW-Q6pj900xYgbjwkizj6tp26cg@mail.gmail.com>
	(Geert Uytterhoeven's message of "Thu, 14 Jan 2016 21:23:57 +0100")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Geert Uytterhoeven <geert@linux-m68k.org> writes:

> On Wed, Jan 13, 2016 at 5:55 AM, Linux Kernel Mailing List
> <linux-kernel@vger.kernel.org> wrote:
>> Commit:     46d703a775394e4724509ff55cdda41d228c028c
>>    brcmfmac: Unify methods to define and map firmware files.
>

[...]

> This change breaks the build with gcc < 4.3:
>
>     drivers/net/wireless/broadcom/brcm80211/brcmfmac/sdio.c:598:
> error: redefinition of =E2=80=98__UNIQUE_ID_firmware598=E2=80=99
>     drivers/net/wireless/broadcom/brcm80211/brcmfmac/sdio.c:598:
> error: previous definition of =E2=80=98__UNIQUE_ID_firmware598=E2=80=99=
 was here
>     drivers/net/wireless/broadcom/brcm80211/brcmfmac/sdio.c:599:
> error: redefinition of =E2=80=98__UNIQUE_ID_firmware600=E2=80=99
>     drivers/net/wireless/broadcom/brcm80211/brcmfmac/sdio.c:599:
> error: previous definition of =E2=80=98__UNIQUE_ID_firmware600=E2=80=99=
 was here
>     ...
>
> The reason is that BRCMF_FW_NVRAM_DEF() expands to two instances of
> MODULE_FIRMWARE():
>
>> --- a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/firmware.h
>> +++ b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/firmware.h
>>
>> +#define BRCMF_FW_NVRAM_DEF(fw_nvram_name, fw, nvram) \
>> +static const char BRCM_ ## fw_nvram_name ## _FIRMWARE_NAME[] =3D \
>> +       BRCMF_FW_DEFAULT_PATH fw; \
>> +static const char BRCM_ ## fw_nvram_name ## _NVRAM_NAME[] =3D \
>> +       BRCMF_FW_DEFAULT_PATH nvram; \
>> +MODULE_FIRMWARE(BRCMF_FW_DEFAULT_PATH fw); \
>> +MODULE_FIRMWARE(BRCMF_FW_DEFAULT_PATH nvram)
>
> When compiling using gcc < 4.3, __UNIQUE_ID() uses __LINE__ instead o=
f
> __COUNTER__, as the latter is not available. Hence it derives a "uniq=
ue" ID
> from the same source line number, causing a redefinition.

Hante, what should we do? We need to fix this build breakage ASAP.

--=20
Kalle Valo
