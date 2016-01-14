From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: brcmfmac build failure with gcc < 4.3 due to __UNIQUE_ID() clash
 (was: Re: brcmfmac: Unify methods to define and map firmware files.)
Date: Thu, 14 Jan 2016 21:23:57 +0100
Message-ID: <CAMuHMdWYrQtWUwPJ0i95WphvW-Q6pj900xYgbjwkizj6tp26cg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Kalle Valo <kvalo@codeaurora.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	brcm80211-dev-list@broadcom.com,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Hante Meuleman <meuleman@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Hante,

On Wed, Jan 13, 2016 at 5:55 AM, Linux Kernel Mailing List
<linux-kernel@vger.kernel.org> wrote:
> Commit:     46d703a775394e4724509ff55cdda41d228c028c
>    brcmfmac: Unify methods to define and map firmware files.

> --- a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/pcie.c
> +++ b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/pcie.c
> @@ -44,25 +44,29 @@ enum brcmf_pcie_state {
>         BRCMFMAC_PCIE_STATE_UP
>  };
>
> -
> -#define BRCMF_PCIE_43602_FW_NAME               "brcm/brcmfmac43602-p=
cie.bin"
> -#define BRCMF_PCIE_43602_NVRAM_NAME            "brcm/brcmfmac43602-p=
cie.txt"
> -#define BRCMF_PCIE_4350_FW_NAME                        "brcm/brcmfma=
c4350-pcie.bin"
> -#define BRCMF_PCIE_4350_NVRAM_NAME             "brcm/brcmfmac4350-pc=
ie.txt"
> -#define BRCMF_PCIE_4356_FW_NAME                        "brcm/brcmfma=
c4356-pcie.bin"
> -#define BRCMF_PCIE_4356_NVRAM_NAME             "brcm/brcmfmac4356-pc=
ie.txt"
> -#define BRCMF_PCIE_43570_FW_NAME               "brcm/brcmfmac43570-p=
cie.bin"
> -#define BRCMF_PCIE_43570_NVRAM_NAME            "brcm/brcmfmac43570-p=
cie.txt"
> -#define BRCMF_PCIE_4358_FW_NAME                        "brcm/brcmfma=
c4358-pcie.bin"
> -#define BRCMF_PCIE_4358_NVRAM_NAME             "brcm/brcmfmac4358-pc=
ie.txt"
> -#define BRCMF_PCIE_4359_FW_NAME                        "brcm/brcmfma=
c4359-pcie.bin"
> -#define BRCMF_PCIE_4359_NVRAM_NAME             "brcm/brcmfmac4359-pc=
ie.txt"
> -#define BRCMF_PCIE_4365_FW_NAME                        "brcm/brcmfma=
c4365b-pcie.bin"
> -#define BRCMF_PCIE_4365_NVRAM_NAME             "brcm/brcmfmac4365b-p=
cie.txt"
> -#define BRCMF_PCIE_4366_FW_NAME                        "brcm/brcmfma=
c4366b-pcie.bin"
> -#define BRCMF_PCIE_4366_NVRAM_NAME             "brcm/brcmfmac4366b-p=
cie.txt"
> -#define BRCMF_PCIE_4371_FW_NAME                        "brcm/brcmfma=
c4371-pcie.bin"
> -#define BRCMF_PCIE_4371_NVRAM_NAME             "brcm/brcmfmac4371-pc=
ie.txt"
> +BRCMF_FW_NVRAM_DEF(43602, "brcmfmac43602-pcie.bin", "brcmfmac43602-p=
cie.txt");
> +BRCMF_FW_NVRAM_DEF(4350, "brcmfmac4350-pcie.bin", "brcmfmac4350-pcie=
=2Etxt");
> +BRCMF_FW_NVRAM_DEF(4356, "brcmfmac4356-pcie.bin", "brcmfmac4356-pcie=
=2Etxt");
> +BRCMF_FW_NVRAM_DEF(43570, "brcmfmac43570-pcie.bin", "brcmfmac43570-p=
cie.txt");
> +BRCMF_FW_NVRAM_DEF(4358, "brcmfmac4358-pcie.bin", "brcmfmac4358-pcie=
=2Etxt");
> +BRCMF_FW_NVRAM_DEF(4359, "brcmfmac4359-pcie.bin", "brcmfmac4359-pcie=
=2Etxt");
> +BRCMF_FW_NVRAM_DEF(4365B, "brcmfmac4365b-pcie.bin", "brcmfmac4365b-p=
cie.txt");
> +BRCMF_FW_NVRAM_DEF(4366B, "brcmfmac4366b-pcie.bin", "brcmfmac4366b-p=
cie.txt");
> +BRCMF_FW_NVRAM_DEF(4371, "brcmfmac4371-pcie.bin", "brcmfmac4371-pcie=
=2Etxt");
> +
> +static struct brcmf_firmware_mapping brcmf_pcie_fwnames[] =3D {
> +       BRCMF_FW_NVRAM_ENTRY(BRCM_CC_43602_CHIP_ID, 0xFFFFFFFF, 43602=
),
> +       BRCMF_FW_NVRAM_ENTRY(BRCM_CC_4350_CHIP_ID, 0xFFFFFFFF, 4350),
> +       BRCMF_FW_NVRAM_ENTRY(BRCM_CC_4356_CHIP_ID, 0xFFFFFFFF, 4356),
> +       BRCMF_FW_NVRAM_ENTRY(BRCM_CC_43567_CHIP_ID, 0xFFFFFFFF, 43570=
),
> +       BRCMF_FW_NVRAM_ENTRY(BRCM_CC_43569_CHIP_ID, 0xFFFFFFFF, 43570=
),
> +       BRCMF_FW_NVRAM_ENTRY(BRCM_CC_43570_CHIP_ID, 0xFFFFFFFF, 43570=
),
> +       BRCMF_FW_NVRAM_ENTRY(BRCM_CC_4358_CHIP_ID, 0xFFFFFFFF, 4358),
> +       BRCMF_FW_NVRAM_ENTRY(BRCM_CC_4359_CHIP_ID, 0xFFFFFFFF, 4359),
> +       BRCMF_FW_NVRAM_ENTRY(BRCM_CC_4365_CHIP_ID, 0xFFFFFFFF, 4365B)=
,
> +       BRCMF_FW_NVRAM_ENTRY(BRCM_CC_4366_CHIP_ID, 0xFFFFFFFF, 4366B)=
,
> +       BRCMF_FW_NVRAM_ENTRY(BRCM_CC_4371_CHIP_ID, 0xFFFFFFFF, 4371),
> +};
>
>  #define BRCMF_PCIE_FW_UP_TIMEOUT               2000 /* msec */
>
> @@ -202,26 +206,6 @@ enum brcmf_pcie_state {
>  #define BRCMF_PCIE_LINK_STATUS_CTRL_ASPM_ENAB  3
>
>
> -MODULE_FIRMWARE(BRCMF_PCIE_43602_FW_NAME);
> -MODULE_FIRMWARE(BRCMF_PCIE_43602_NVRAM_NAME);
> -MODULE_FIRMWARE(BRCMF_PCIE_4350_FW_NAME);
> -MODULE_FIRMWARE(BRCMF_PCIE_4350_NVRAM_NAME);

This change breaks the build with gcc < 4.3:

    drivers/net/wireless/broadcom/brcm80211/brcmfmac/sdio.c:598:
error: redefinition of =E2=80=98__UNIQUE_ID_firmware598=E2=80=99
    drivers/net/wireless/broadcom/brcm80211/brcmfmac/sdio.c:598:
error: previous definition of =E2=80=98__UNIQUE_ID_firmware598=E2=80=99=
 was here
    drivers/net/wireless/broadcom/brcm80211/brcmfmac/sdio.c:599:
error: redefinition of =E2=80=98__UNIQUE_ID_firmware600=E2=80=99
    drivers/net/wireless/broadcom/brcm80211/brcmfmac/sdio.c:599:
error: previous definition of =E2=80=98__UNIQUE_ID_firmware600=E2=80=99=
 was here
    ...

The reason is that BRCMF_FW_NVRAM_DEF() expands to two instances of
MODULE_FIRMWARE():

> --- a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/firmware.h
> +++ b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/firmware.h
>
> +#define BRCMF_FW_NVRAM_DEF(fw_nvram_name, fw, nvram) \
> +static const char BRCM_ ## fw_nvram_name ## _FIRMWARE_NAME[] =3D \
> +       BRCMF_FW_DEFAULT_PATH fw; \
> +static const char BRCM_ ## fw_nvram_name ## _NVRAM_NAME[] =3D \
> +       BRCMF_FW_DEFAULT_PATH nvram; \
> +MODULE_FIRMWARE(BRCMF_FW_DEFAULT_PATH fw); \
> +MODULE_FIRMWARE(BRCMF_FW_DEFAULT_PATH nvram)

When compiling using gcc < 4.3, __UNIQUE_ID() uses __LINE__ instead of
__COUNTER__, as the latter is not available. Hence it derives a "unique=
" ID
from the same source line number, causing a redefinition.

Gr{oetje,eeting}s,

                        Geert
