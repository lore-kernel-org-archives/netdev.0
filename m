From: Kasper Dupont <kasperd@cpvhh.24.jul.2011.kasperd.net>
Subject: Re: r8169 driver crashes in 2.6.32.43
Date: Thu, 28 Jul 2011 10:48:21 +0200
Message-ID: <20110728084821.GA24125@colin.search.kasperd.net>
References: <20110724195831.GA8718@colin.search.kasperd.net> <20110724201626.GB24418@zoreil.com> <20110725103643.GA11135@colin.search.kasperd.net> <20110728070455.GA11251@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ivecera@redhat.com, hayeswang@realtek.com, gregkh@suse.de,
	netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nfitmail.nfit.au.dk ([130.225.31.129]:47507 "EHLO
	smtp.nfit.au.dk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750734Ab1G1Is1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jul 2011 04:48:27 -0400
Content-Disposition: inline
In-Reply-To: <20110728070455.GA11251@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 28/07/11 09.04, Francois Romieu wrote:
> Kasper Dupont <kasperd@cpvhh.24.jul.2011.kasperd.net> :
> [...]
> > [    1.045727] pata_sch 0000:00:1f.1: setting latency timer to 64
> > [    1.045946] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
> > [    1.046061] r8169 0000:02:00.0: PCI INT A -> GSI 16 (level, low)=
 -> IRQ 16
> > [    1.046201] r8169 0000:02:00.0: setting latency timer to 64
> > [    1.046257]   alloc irq_desc for 24 on node -1
> > [    1.046263]   alloc kstat_irqs on node -1
> > [    1.046284] r8169 0000:02:00.0: irq 24 for MSI/MSI-X
> > [    1.048097] eth0: RTL8168c/8111c at 0xf8076000, 00:01:c0:09:a1:2=
5, XID 1c4000c0 IRQ 24
>=20
> RTL_GIGA_MAC_VER_22
>=20
> [...]
> > [    1.082178] eth1: RTL8168c/8111c at 0xf8096000, 00:01:c0:09:a1:2=
6, XID 1c4000c0 IRQ 25
>=20
> sic.
>=20
> I miss it (the light fast crash prone motherboard from hell does not =
count).
>=20
> [...]
> > It works on 2.6.32.32 it crashes on 2.6.32.33. I tried to
> > take 2.6.32.43 and apply 1519e57fe81c14bb8fa4855579f19264d1ef63b4,
> > that did not help. 2.6.32.43 crashes with and without that patch.
>=20
> 1519e57fe81c14bb8fa4855579f19264d1ef63b4 does not help RTL_GIGA_MAC_V=
ER_22
> proper but you may apply it, then move the 'case RTL_GIGA_MAC_VER_22:=
'
> statement a few line below and see if it helps (assuming the fifo ove=
rflow
> event may be ignored):

I tried to apply both 1519e57fe81c14bb8fa4855579f19264d1ef63b4
and f60ac8e7ab7cbb413a0131d5665b053f9f386526. It still crashes,
the first two times I booted that exact build it printed out a
stackdump just before crashing. I have pictures of the two
stack dumps in case that is any help, but unfortunately they
were too deep to fit on 25 lines.

>=20
> diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
> index 7d9c650..33c0ead 100644
> --- a/drivers/net/r8169.c
> +++ b/drivers/net/r8169.c
> @@ -5383,7 +5383,6 @@ static irqreturn_t rtl8169_interrupt(int irq, v=
oid *dev_instance)
>  			switch (tp->mac_version) {
>  			/* Work around for rx fifo overflow */
>  			case RTL_GIGA_MAC_VER_11:
> -			case RTL_GIGA_MAC_VER_22:
>  			case RTL_GIGA_MAC_VER_26:
>  				netif_stop_queue(dev);
>  				rtl8169_tx_timeout(dev);
> @@ -5393,6 +5392,7 @@ static irqreturn_t rtl8169_interrupt(int irq, v=
oid *dev_instance)
>  			case RTL_GIGA_MAC_VER_19:
>  			case RTL_GIGA_MAC_VER_20:
>  			case RTL_GIGA_MAC_VER_21:
> +			case RTL_GIGA_MAC_VER_22:
>  			case RTL_GIGA_MAC_VER_23:
>  			case RTL_GIGA_MAC_VER_24:
>  			case RTL_GIGA_MAC_VER_27:

I tried applying this one as well (in addition to the previous
two). It no longer crashes, but now the network stops working
after the first few packets have been transmitted.

What exactly was 649f25c389e9498923b459bbffff41a2fd1d7a64
trying to fix in the first place? Before that patch the
network on this machine was running fast and stable.

--=20
Kasper Dupont -- Rigtige m=E6nd skriver deres egne backupprogrammer
#define _(_)"d.%.4s%."_"2s" /* This is my email address */
char*_=3D"@2kaspner"_()"%03"_("4s%.")"t\n";printf(_+11,_+6,_,11,_+2,_+7=
,_+6);
