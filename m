From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: Does tc-prio really work as advertised?
Date: Mon, 26 Nov 2007 23:25:14 +0100
Message-ID: <474B47CA.1050802@o2.pl>
References: <292416.28036.qm@web51406.mail.re2.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	OLSR discussion and development <olsr-users@olsr.org>
To: Joerg Pommnitz <pommnitz@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx12.go2.pl ([193.17.41.142]:38172 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753089AbXKZWXu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Nov 2007 17:23:50 -0500
In-Reply-To: <292416.28036.qm@web51406.mail.re2.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Joerg Pommnitz wrote, On 11/23/2007 03:47 PM:

> Hello all,
> I might make a fool out of me, but I think the prio qdisc doesn't work as advertised in any document I could lay my hands on.


Marketing?

> 
> My problem was that the link quality reported by the olsr.org olsrd degraded depending on the amount of payload traffic transferred through an adhoc/mesh interface. The LQ is calculated from the packet loss of LQ Hello packets sent through this interface. To make sure normal traffic does not interfere with this value, olsrd sets the TOS field to 0x10 (Minimize-Delay) by default. This should give olsr traffic the highest priority on the link.
> 
> Investigating this issue I replaced the default Pfifo_fast with a prio qdisc and attached a pfifo on each of the bands:
> 
>     INTERFACE=wifi0
>     tc qdisc add dev $INTERFACE root handle 1: prio
>     tc qdisc add dev $INTERFACE parent 1:1 handle 10: pfifo
>     tc qdisc add dev $INTERFACE parent 1:2 handle 20: pfifo
>     tc qdisc add dev $INTERFACE parent 1:3 handle 30: pfifo
> 
> The I used ping -Q TOSVALUE to send packets with different TOS values through the interface. tcpdump confirmed the correct TOS values in the outgoing packets.
> 
> With "tc -s qdisc ls dev wifi0" I could observe the effects of the different TOS values. The result: no effect at all! Every single packet used the band indicated by the first value in the priomap (e.g. band 1 by default, in my case the pfifo with handle 20:). I can't square this observation with the available documentation.
> 
> Looking at the source code, it seems that sched_prio uses the skb->priority value to select the outgoing band. According to some documentation I found, an application can set this value.
> 
> Now I'm at a loss. I can work around this problem with filters, but I don't think that this is the correct solution. Any suggestions?
> 

Are you doing this on the same box? I was tracing this long time ago too, and, if
I didn't miss something, it was about the place! So, as I recall (after finding
some old message) this TOS is considered only for packets going through the FORWARD
chain. (But, I haven't checked this at all now, so "no complaints"...)

Regards,
Jarek P.
