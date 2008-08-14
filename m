From: Pekka Savola <pekkas@netcore.fi>
Subject: interface down: v6/v4 address deletion difference
Date: Thu, 14 Aug 2008 20:25:11 +0300 (EEST)
Message-ID: <alpine.LRH.1.10.0808142017050.23001@netcore.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from netcore.fi ([193.94.160.1]:38949 "EHLO netcore.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752166AbYHNRZR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Aug 2008 13:25:17 -0400
Received: from netcore.fi (localhost [127.0.0.1])
	by netcore.fi (8.13.8/8.13.8) with ESMTP id m7EHPCwP023192
	for <netdev@vger.kernel.org>; Thu, 14 Aug 2008 20:25:12 +0300
Received: from localhost (pekkas@localhost)
	by netcore.fi (8.13.8/8.13.8/Submit) with ESMTP id m7EHPB7b023188
	for <netdev@vger.kernel.org>; Thu, 14 Aug 2008 20:25:12 +0300
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I recall there was discussion about this a couple of years back, but I 
couldn't find it for all I could try.

There seems to be a difference in how v4/v6 addresses are handled when 
interface goes down (manually added addresses are gone forever 
regardless of whether it's tentative or nor; link local address is 
deleted but reappears when link is back).

Example on 2.6.25.10-86.fc9 using pan0 interface (just because it's 
easiest to play with it):

# ip l set up dev pan
# ip a a 10.0.0.1/24 dev pan0
# ip -6 a a 2001::1/64 dev pan0
# ip a l dev pan0
8: pan0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue 
state UNKNOWN
     link/ether 36:ca:62:2a:71:7b brd ff:ff:ff:ff:ff:ff
     inet 10.0.0.1/24 scope global pan0
     inet6 2001::1/64 scope global
        valid_lft forever preferred_lft forever
     inet6 fe80::34ca:62ff:fe2a:717b/64 scope link
        valid_lft forever preferred_lft forever
# ip l set down dev pan0
# ip a l dev pan0
8: pan0: <BROADCAST,MULTICAST> mtu 1500 qdisc noqueue state DOWN
     link/ether 36:ca:62:2a:71:7b brd ff:ff:ff:ff:ff:ff
     inet 10.0.0.1/24 scope global pan0
# ip l set up dev pan0
# ip a l dev pan0
8: pan0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue 
state UNKNOWN
     link/ether 36:ca:62:2a:71:7b brd ff:ff:ff:ff:ff:ff
     inet 10.0.0.1/24 scope global pan0
     inet6 fe80::34ca:62ff:fe2a:717b/64 scope link tentative
        valid_lft forever preferred_lft forever
(and after a while 'tentative' flag goes away)

Shouldn't behaviour be consistent across v4/v6?

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
