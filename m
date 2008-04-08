From: "Eric B." <ebenze@hotmail.com>
Subject: How to verify/log/debug which route table being used?
Date: Mon, 7 Apr 2008 23:44:07 -0400
Message-ID: <fteppj$kl8$1@ger.gmane.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:47797 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750942AbYDHDuE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Apr 2008 23:50:04 -0400
Received: from root by ciao.gmane.org with local (Exim 4.43)
	id 1Jj4qQ-0006GC-OJ
	for netdev@vger.kernel.org; Tue, 08 Apr 2008 03:50:02 +0000
Received: from 76-10-148-227.dsl.teksavvy.com ([76.10.148.227])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 08 Apr 2008 03:50:02 +0000
Received: from ebenze by 76-10-148-227.dsl.teksavvy.com with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 08 Apr 2008 03:50:02 +0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I'm trying to configure my server to route different packets via different
kernel route tables.  I thought I had things configured properly, but from
some quick tests, return packets from my server don't seem to be making the
return trip.  I look at my iptables log output and see that my packets are
formed as I would expect, but the logs on my router don't show them showing
up.

Is there a way I can verify / validate that my packets are acutally using
the routing table I have specified and are being retransmitted to the
correct gateway?

My setup is as follows (RHEL 4.2):
# iptables -t mangle -A PREROUTING -d 192.168.104.64 -j MARK --set-mark 3
# iptables -t nat -A POSTROUTING -m mark --mark 3 -j SNAT --to-source
192.168.104.64
# ip rule add fwmark 3 table 3
# ip route add unicast default via 192.168.104.251 table 3

My goal is as follows:
My server is multi-homed; the same NIC serving both 192.168.101.64 and
192.168.104.64.
I'm looking to configure it such that any incoming packets destined for
192.168.104.64 get a mark added to them.  Any response to that packet will
get routed to gateway 192.168.104.251 (from the default route in table 3),
and have its source address modified to 192.168.104.64.

However, if I check my logs on my router at 192.168.104.251, I don't see any
return packets showing up.

Is there any way I can debug (using tcpdump somehow?  Although not quite
sure what to look for in its output - help would be appreciated how best to
use it) the outgoing packets to ensure that they are being sent to
192.168.104.251, and not my default gateway from my main routing table?

Thanks!

Eric



-- 
Posted via a free Usenet account from http://www.teranews.com




