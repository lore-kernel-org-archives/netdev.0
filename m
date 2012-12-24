From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH] brcmsmac: initialize morepending in brcms_b_recv()
Date: Mon, 24 Dec 2012 13:02:18 +0100
Message-ID: <CAMuHMdXJtmXJ65mKi4uFZb4GQuU0SBMTYmr+Rt6_QJcZnR1sUQ@mail.gmail.com>
References: <1356210434-28435-1-git-send-email-geert@linux-m68k.org>
	<50D73FE1.6080907@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Piotr Haber <phaber@broadcom.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, brcm80211-dev-list@broadcom.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Arend van Spriel <arend@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <50D73FE1.6080907@broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Dec 23, 2012 at 6:31 PM, Arend van Spriel <arend@broadcom.com> =
wrote:
> On 12/22/2012 10:07 PM, Geert Uytterhoeven wrote:
>> drivers/net/wireless/brcm80211/brcmsmac/main.c: In function =E2=80=98=
brcms_b_recv=E2=80=99:
>> drivers/net/wireless/brcm80211/brcmsmac/main.c:7636: warning: =E2=80=
=98morepending=E2=80=99 may be used uninitialized in this function
>
> Reading the code this warning seems to be invalid except when RXBND i=
s
> defined as zero, which would make the whole function totally bogus.
> Would be good to have a WARN_ON(!RXBND) in brcms_b_attach().

I thought about the bound =3D false case immediately ending the loop.
But on closer look, it seems I missed that n and bound_limit are uint, =
not int.
So it's indeed unlikely to happen.

> I don't like pleasing a compiler with unnecessary initializers but I =
am
> also for builds with zero warnings. So...
>
> Acked-by: Arend van Spriel <arend@broadcom.com>
>> Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
>> ---
>>  drivers/net/wireless/brcm80211/brcmsmac/main.c |    2 +-
>>  1 files changed, 1 insertions(+), 1 deletions(-)
>>
>> diff --git a/drivers/net/wireless/brcm80211/brcmsmac/main.c b/driver=
s/net/wireless/brcm80211/brcmsmac/main.c
>> index 17594de..5f0f444 100644
>> --- a/drivers/net/wireless/brcm80211/brcmsmac/main.c
>> +++ b/drivers/net/wireless/brcm80211/brcmsmac/main.c
>> @@ -7633,7 +7633,7 @@ brcms_b_recv(struct brcms_hardware *wlc_hw, ui=
nt fifo, bool bound)
>>
>>       uint n =3D 0;
>>       uint bound_limit =3D bound ? RXBND : -1;
>> -     bool morepending;
>> +     bool morepending =3D false;
>>
>>       skb_queue_head_init(&recv_frames);

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-=
m68k.org

In personal conversations with technical people, I call myself a hacker=
=2E But
when I'm talking to journalists I just say "programmer" or something li=
ke that.
                                -- Linus Torvalds
