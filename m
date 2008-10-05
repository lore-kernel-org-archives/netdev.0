From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: 802.1p, skb->priority, CoS for transit traffic not working?
Date: Sun, 5 Oct 2008 22:03:37 +0300
Message-ID: <200810052203.37436.denys@visp.net.lb>
References: <200810051935.56616.denys@visp.net.lb> <48E8F1A3.3070900@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2.globalproof.net ([194.146.153.25]:39171 "EHLO
	relay2.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755552AbYJETcw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Oct 2008 15:32:52 -0400
In-Reply-To: <48E8F1A3.3070900@trash.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sunday 05 October 2008, Patrick McHardy wrote:
> Denys Fedoryshchenko wrote:
> > I'm trying to set CoS tag, to manage priorities on my microwave link.
> > Possible such setup will be very useful also to set classify traffic
> > passing QoS. A lot of hardware support this simple L2 QoS.
> >
> > [...]
> > Is there a way to make work changing transit packets 802.1p values?
>
> Bridging traffic to a VLAN device should work, you can then
> define the priority for the device. I'm not aware of an easier
> method, but I believe act_pedit should also be able to do this.

Seems my silly mistake, i used wrong option in skbedit (first which i seen in 
example). 
Thanks to Intel guys, now it is possible also by this way:

tc qdisc del dev eth2.10 root
tc qdisc add dev eth2.10 root handle 1: prio
/sbin/tc filter add dev eth2.10 parent 1:0 protocol all u32 match u32 0 0 
action skbedit priority 3

So it is possible now to do 802.1p marking on router(not bridge), by u32 
filter or whatever.

tc qdisc del dev eth2.10 root
tc qdisc add dev eth2.10 root handle 1: prio
/sbin/tc filter add dev eth2.10 parent 1:0 protocol all u32 match u32 0 0 
action skbedit priority 3

Like this it works


And thanks again, i am really impressed by opensource initiatives of Intel, 
and quality/performance/cost of their network products.
