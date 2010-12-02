From: Andrew Watts <akwatts@ymail.com>
Subject: Re: kernel panic with time-stamping in phy devices (monitor mode)
Date: Thu, 2 Dec 2010 10:21:22 -0800 (PST)
Message-ID: <252636.43070.qm@web111007.mail.gq1.yahoo.com>
References: <1291307884.2871.69.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm26-vm0.bullet.mail.sp2.yahoo.com ([98.139.91.230]:48216 "HELO
	nm26-vm0.bullet.mail.sp2.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755427Ab0LBSVY convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Dec 2010 13:21:24 -0500
In-Reply-To: <1291307884.2871.69.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--- On Thu, 12/2/10, Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Le jeudi 02 d=E9cembre 2010 =E0 08:05
> -0800, Andrew Watts a =E9crit :
> > Hi.
> >=20
> > The 'time stamping in phy devices' code introduced in
> 2.6.36
> > (c1f19b51d1d87f3e3bb7e6648f43f7d57ed2da6b et al.)
> triggers
> > kernel panics when wireless devices are placed in
> monitor mode
> > (tested with b43 and ath5k devices on a 32-bit
> system).
> >=20
> > To reproduce, set CONFIG_NETWORK_PHY_TIMESTAMPING=3Dy
> and put a
> > wireless device into monitor mode:
> >=20
> >=A0 # ifconfig wlan0 down
> >=A0 # iwconfig wlan0 mode monitor=20
> >=A0 # ifconfig wlan0 up
> >=20
> > ~ Andy
> >=20
> > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> >=20
> >=A0 [<c14455ad>] ? __alloc_skb+0x53/0xf8
> >=A0 [<f92fdd57>] ? b43_dma_rx+0x18a/0x342
> [b43]
> >=A0 [<f92e8475>] ?
> b43_do_interrupt_thread+0x420/0x92e [b43]
> >=A0 [<c1027731>] ? __dequeue_entity+0x31/0x35
> >=A0 [<c1027a44>] ? set_next_entity+0xad/0xbb
> >=A0 [<f92e899b>] ?
> b43_interrupt_thread_handler+0x18/0x2b [b43]
> >=A0 [<c107c378>] ? irq_thread+0xb6/0x19e
> >=A0 [<c15625a0>] ? schedule+0x254/0x566
> >=A0 [<c107c2c2>] ? irq_thread+0x0/0x19e
> >=A0 [<c10448b1>] ? kthread+0x67/0x69
> >=A0 [<c104484a>] ? kthread+0x0/0x69
> >=A0 [<c100323e>] ?
> kernel_thread_helper+0x6/0x18
> > Code: 4c 24 14 8b 88 a8 00 00 00 89 4c 24 10 89 54 24
> 0c 8b
> > 40 50 89 44 24 08 8b 45 04 89 44 24 04 c7 04 24 30 74
> 7a c1
> > e8 b5 d2 11 00 <0f> 0b eb fe 55 89 e5 56 53 83
> ec 24 8b 88
> > a0 00 00 00 8b 58 54
> > EIP: [<c1444ea0>] skb_push+0x7d/0x81 SS:ESP
> 0068:cee01d78
> > ---[ end trace af1c99818e62b195 ]---
> > Kernel panic - not syncing: Fatal exception in
> interrupt
> > Pid: 6674, comm: irq/18-b43 Tainted: G=A0
> =A0=A0=A0D=A0 =A0=A0=A02.6.36.1
> > Call Trace:
> >=A0 [<c156217d>] ? printk+0x28/0x2a
> >=A0 [<c156205c>] panic+0x57/0x150
> >=A0 [<c1564adf>] oops_begin+0x0/0x40
> >=A0 [<c1004e36>] die+0x49/0x5d
> >=A0 [<c1564304>] do_trap+0x84/0xad
> >=A0 [<c10037e5>] ? do_invalid_op+0x0/0x93
> >=A0 [<c100386b>] do_invalid_op+0x86/0x93
> >=A0 [<c1444ea0>] ? skb_push+0x7d/0x81
> >=A0 [<c15640b9>] error_code+0x65/0x6c
> >=A0 [<c1444ea0>] ? skb_push+0x7d/0x81
> >=A0 [<c145f721>] ?
> skb_defer_rx_timestamp+0x12/0x5a
> >=A0 [<c145f721>]
> skb_defer_rx_timestamp+0x12/0x5a
> >=A0 [<c144d23c>] netif_receive_skb+0x1f/0x47
> >=A0 [<c153a6e8>] ieee80211_rx+0x661/0x8e1
> >=A0 [<f85daca2>] ? ssb_pci_read32+0x19/0x31
> [ssb]
> >=A0 [<f92e54cf>] ? b43_tsf_read+0x2a/0x47
> [b43]
> >=A0 [<f92f8d42>] b43_rx+0x24c/0x5eb [b43]
> >=A0 [<c14455ad>] ? __alloc_skb+0x53/0xf8
> >=A0 [<f92fdd57>] b43_dma_rx+0x18a/0x342 [b43]
> >=A0 [<f92e8475>]
> b43_do_interrupt_thread+0x420/0x92e [b43]
> >=A0 [<c1027731>] ? __dequeue_entity+0x31/0x35
> >=A0 [<c1027a44>] ? set_next_entity+0xad/0xbb
> >=A0 [<f92e899b>]
> b43_interrupt_thread_handler+0x18/0x2b [b43]
> >=A0 [<c107c378>] irq_thread+0xb6/0x19e
> >=A0 [<c15625a0>] ? schedule+0x254/0x566
> >=A0 [<c107c2c2>] ? irq_thread+0x0/0x19e
> >=A0 [<c10448b1>] kthread+0x67/0x69
> >=A0 [<c104484a>] ? kthread+0x0/0x69
> >=A0 [<c100323e>]
> kernel_thread_helper+0x6/0x18
> >=20
> >=20
>=20
> Thanks for the report
>=20
> Please try following patch.
>=20
> diff --git a/net/core/timestamping.c
> b/net/core/timestamping.c
> index dac7ed6..a710ab0 100644
> --- a/net/core/timestamping.c
> +++ b/net/core/timestamping.c
> @@ -96,7 +96,10 @@ bool skb_defer_rx_timestamp(struct
> sk_buff *skb)
>  =A0=A0=A0 struct phy_device *phydev;
>  =A0=A0=A0 unsigned int type;
> =20
> -=A0=A0=A0 skb_push(skb, ETH_HLEN);
> +=A0=A0=A0 if (skb->data - ETH_HLEN <
> skb->head)
> +=A0=A0=A0 =A0=A0=A0 return false;
> +
> +=A0=A0=A0 __skb_push(skb, ETH_HLEN);
> =20
>  =A0=A0=A0 type =3D classify(skb);
>  =20

I can confirm that I get no kernel panics after
applying that patch.

~ Andy



     =20
