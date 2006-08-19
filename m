From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [RFC] HOWTO use NAPI to reduce TX interrupts
Date: Sat, 19 Aug 2006 13:25:18 +0200
Message-ID: <200608191325.19557.arnd@arndb.de>
References: <20060818220700.GG26889@austin.ibm.com> <200608190256.26373.arnd@arndb.de> <44E7BB7F.7030204@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linuxppc-dev@ozlabs.org, akpm@osdl.org,
	James K Lewis <jklewis@us.ibm.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Jeff Garzik <jgarzik@pobox.com>,
	Jens Osterkamp <Jens.Osterkamp@de.ibm.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.186]:44782 "EHLO
	moutng.kundenserver.de") by vger.kernel.org with ESMTP
	id S1751723AbWHSLZq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Aug 2006 07:25:46 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <44E7BB7F.7030204@osdl.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sunday 20 August 2006 03:31, Stephen Hemminger wrote:
>=20
> The reason reclaim via poll() is efficient is because it avoid causin=
g a=20
> softirq that is
> necessary when skb_free_irq() is done. Instead it reuses the softirq=20
> from the poll() routine.=20

Ok, I completely missed this point so far, thanks for the info.

> Like all Rx NAPI, using poll() for reclaim means:=20
> =A0 =A0 + aggregating multiple frames in one irq
> =A0 =A0 - increased overhead of twiddling with the IRQ mask
> =A0 =A0 - more ways to get driver stuck

What is the best way to treat the IRQ mask for TX interrupts?
I guess it should be roughly:

- off when we expect ->poll() to be called, i.e. after calling
  netif_rx_schedule() or returning after a partial rx from poll().
- off when there are no packets left in the TX queue
- on while RX interrupts are on and we're waiting for packets
  to be transmitted.

> Some drivers do all their irq work in the poll() routine (including P=
HY=20
> handling).
> This is good if reading the IRQ status does an auto mask operation.
>=20
> The whole NAPI documentation area is a mess and needs a good writer
> to do some major restructuring. It should also be split into referenc=
e=20
> information,
> tutorial and guide sections.

I won't be able to do that work, I'm neither a good writer nor a networ=
king
person.

Do you think we should still merge a section like the text I wrote up, =
even
if it makes the text even less well structured? Should I maybe add it
somewhere else than the appendix?

	Arnd <><
