From: Ben Greear <greearb@candelatech.com>
Subject: Re: Add/Delete IPv6 addresses and netlink
Date: Fri, 20 Jun 2008 22:25:18 -0700
Message-ID: <485C90BE.60301@candelatech.com>
References: <48571470.7010307@candelatech.com> <20080617121821.GC20815@postel.suug.ch> <4857DC95.8000709@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([66.165.47.212]:36186 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750913AbYFUFZZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Jun 2008 01:25:25 -0400
In-Reply-To: <4857DC95.8000709@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Greear wrote:
>
> I'm using the 8139too driver.  I notice that it shows full link
> speed (100-FD) when the NIC is admin down.   Maybe that is causing it 
> to not
> go through an expected state change?
>
> I'll work on doing this same test with a vanilla kernel but on this 
> hardware just in case I've
> screwed something up somewhere...
I just re-did this test on the latest FC8 kernel and the same problem 
appears.

ip link set eth1 down; ip -6 addr flush dev eth1;
Nothing to flush.
ip -6 addr add 2000::9:2/112 scope global dev eth1
ip link set eth1 up
ip -6 addr show dev eth1
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qlen 1000
    inet6 2000::9:2/112 scope global tentative
       valid_lft forever preferred_lft forever
    inet6 fe80::203:2dff:fe04:65b1/64 scope link
       valid_lft forever preferred_lft forever
uname -a
Linux lanforge-65-AF 2.6.25.4-10.fc8 #1 SMP Thu May 22 23:34:09 EDT 2008 
i686 i686 i386 GNU/Linux

I wonder if it's something to do with the 8139too driver.  Can anyone 
else with that NIC
confirm?

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com> 
Candela Technologies Inc  http://www.candelatech.com


