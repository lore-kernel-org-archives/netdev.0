From: Anca Emanuel <anca.emanuel@gmail.com>
Subject: Re: [PATCH] r8169: fix a bug in rtl8169_init_phy()
Date: Sat, 19 Mar 2011 19:20:09 +0200
Message-ID: <AANLkTike8Ggtwjrx64MR4QiPtn1vMF+CVWFJbDrNaVrR@mail.gmail.com>
References: <4D84A46B.1000407@example.com>
	<AANLkTimFGeHYEOxx=h883rRJL463g1CBUDS0wGM-52Nj@mail.gmail.com>
	<1300547930.2831.27.camel@edumazet-laptop>
	<201103191631.07952.oliver@neukum.org>
	<1300548821.2831.28.camel@edumazet-laptop>
	<1300549151.2831.32.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Oliver Neukum <oliver@neukum.org>, piotr@hosowicz.com,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	Francois Romieu <romieu@fr.zoreil.com>,
	David Miller <davem@davemloft.net>,
	Linus Torvalds <torvalds@linux-foundation.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1300549151.2831.32.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Mar 19, 2011 at 5:39 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Le samedi 19 mars 2011 =E0 16:33 +0100, Eric Dumazet a =E9crit :
>> Le samedi 19 mars 2011 =E0 16:31 +0100, Oliver Neukum a =E9crit :
>> > Am Samstag, 19. M=E4rz 2011, 16:18:50 schrieb Eric Dumazet:
>> >
>> > > Problem comes from commit 54405cde762408b00a445466a40da4f7f33a84=
79
>> > > (r8169: support control of advertising.)
>> > >
>> > > Reverting it brings back NIC for me
>> >
>> > Odd. It worked for me. Are you testing on a gigabit switch? Could =
you send
>> > me dmesg? Does it work if you use ethtool to advertise a lower spe=
ed?
>> >
>> > =A0 =A0 Regards
>> > =A0 =A0 =A0 =A0 =A0 =A0 Oliver
>>
>> I found the bug, I am sending a patch in two minutes.
>>
>
> Here it is
>
> [PATCH] r8169: fix a bug in rtl8169_init_phy()
>
> commit 54405cde7624 (r8169: support control of advertising.)
> introduced a bug in rtl8169_init_phy()
>
> Reported-by: Piotr Hosowicz <piotr@hosowicz.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Oliver Neukum <oliver@neukum.org>
> Cc: Francois Romieu <romieu@fr.zoreil.com>
> ---
> =A0drivers/net/r8169.c | =A0 =A04 ++--
> =A01 file changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
> index 5e40351..493b0de 100644
> --- a/drivers/net/r8169.c
> +++ b/drivers/net/r8169.c
> @@ -2685,9 +2685,9 @@ static void rtl8169_init_phy(struct net_device =
*dev, struct rtl8169_private *tp)
> =A0 =A0 =A0 =A0rtl8169_set_speed(dev, AUTONEG_ENABLE, SPEED_1000, DUP=
LEX_FULL,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ADVERTISED_10baseT_Half | ADVERTISED_1=
0baseT_Full |
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ADVERTISED_100baseT_Half | ADVERTISED_=
100baseT_Full |
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 tp->mii.supports_gmii ?
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 (tp->mii.supports_gmii ?
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ADVERTISED_1000baseT_H=
alf |
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ADVERTISED_1000baseT_Fu=
ll : 0);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ADVERTISED_1000baseT_Fu=
ll : 0));
>
> =A0 =A0 =A0 =A0if (RTL_R8(PHYstatus) & TBI_Enable)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0netif_info(tp, link, dev, "TBI auto-ne=
gotiating\n");
>
>
>

Thanks Eric, It Woks now !

My r8169 was not working see:
https://lkml.org/lkml/2011/3/19/19

Tested-by: Anca Emanuel <anca.emanuel@gmail.com>
