From: Brian Haley <brian.haley@hp.com>
Subject: Re: BUG: IPv6 stops working after a while, needs ip ne del command
 to reset
Date: Wed, 01 Sep 2010 10:40:26 -0400
Message-ID: <4C7E65DA.5020106@hp.com>
References: <1282024802.2487.687.camel@edumazet-laptop> <alpine.DEB.1.10.1008171053230.21857@red.crap.retrofitta.se> <1282050920.2448.47.camel@edumazet-laptop> <alpine.DEB.1.10.1008171547090.21857@red.crap.retrofitta.se> <1282055659.2448.58.camel@edumazet-laptop> <alpine.DEB.1.10.1008171737260.21857@red.crap.retrofitta.se> <20100817171115.GA4134@mcarlson.broadcom.com> <alpine.DEB.1.10.1008171928160.21857@red.crap.retrofitta.se> <20100817183112.GA4351@mcarlson.broadcom.com> <alpine.DEB.1.10.1008172035520.21857@red.crap.retrofitta.se> <20100818012318.GA4630@mcarlson.broadcom.com> <alpine.DEB.1.10.1008180900350.21857@red.crap.retrofitta.se> <alpine.DEB.1.10.1009011034560.31938@red.crap.retrofitta.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Matt Carlson <mcarlson@broadcom.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Michael Chan <mchan@broadcom.com>
To: Thomas Habets <thomas@habets.pp.se>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.1.10.1009011034560.31938@red.crap.retrofitta.se>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Thomas,

On 09/01/2010 05:21 AM, Thomas Habets wrote:
> 
> I've continued this a bit off-list but thought I would summarize for the
> archives.
> 
> 
> Summary
> -------
> It looks like a firmware issue on the network card. When ILO is enabled
> it shares the first network card with the OS. When it does this
> multicast is broken. When multicast (on a L2 level) is broken IPv6
> neighbor discovery breaks. Only eth0 breaks, eth1 is unaffected.

So are you running with this set to "Shared Network Port" mode?  I'm
guessing you are.

> System
> ------
> HP Proliant DL320 G5p
> Xeon 3GHz
> 1GB RAM
> Arch: amd64
> NIC: Broadcom Corporation NetXtreme BCM5715 Gigabit Ethernet (rev a3)

There was another report on netdev back in 11/2008 on this exact hardware,
with the same problem.

> Problem
> -------
> Buggy box will not answer IPv6 ND or ping to ff02::1. May work at some
> point in the boot process, but once box is fully booted it does not.

I dug-up my notes on the problem, and from what I can tell, the receive
multicast filters on the NIC were getting removed, causing both incoming
IPv6 and IPv4 multicast packets to get dropped.  I'm not sure if there
was ever a fix developed, or if we ever came to a conclusion on where the
bug was - iLO, tg3, or some other area.

-Brian
