From: "Alex Lyakas" <alex@zadarastorage.com>
Subject: Re: bond failover doesn't happen when active slave link is up, but there is no connectivity
Date: Tue, 4 Mar 2014 13:51:23 +0200
Message-ID: <83DC65F1422D438386BA1C7D3699E742@alyakaslap>
References: <62EB227014B44F00A9ACC9C781887FC8@alyakaslap> <53152F0D.2050500@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain;
	format=flowed;
	charset="UTF-8";
	reply-type=original
Content-Transfer-Encoding: 7bit
To: "Ding Tianhong" <dingtianhong@huawei.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f52.google.com ([74.125.82.52]:35381 "EHLO
	mail-wg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756757AbaCDLvb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2014 06:51:31 -0500
Received: by mail-wg0-f52.google.com with SMTP id k14so3024759wgh.35
        for <netdev@vger.kernel.org>; Tue, 04 Mar 2014 03:51:30 -0800 (PST)
In-Reply-To: <53152F0D.2050500@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Ding,
I will try to explain the problem better.

I have a bond in active-backup mode, with fail_over_mac=1. Bond has a good 
active slave with "link up" and it also has a non-active slave (also with 
"link up"). The active slave interface is connected to a switch at some 
port=X. Now imagine that due to configuration problem of the switch (or some 
bug in switch FW), all packets sent to port X are silently dropped by the 
switch. But the active slave link is still "up". In that case, the bond will 
not failover to the second slave, even through the active slave has no 
connectivity.
The question is how this can be addressed.

Thanks,
Alex.



-----Original Message----- 
From: Ding Tianhong
Sent: 04 March, 2014 3:40 AM
To: Alex Lyakas ; netdev@vger.kernel.org
Subject: Re: bond failover doesn't happen when active slave link is up, but 
there is no connectivity

On 2014/3/4 0:49, Alex Lyakas wrote:
> Greetings all,
> We are using bonding interfaces in active-backup (1) mode, with 
> "fail_over_mac" set to "active" (1), with miimon=100 and two slaves. The 
> slaves are "either regular" network interfaces, or vlan interfaces created 
> with "vconfig" over "regular" interfaces. One of the slaves is defined as 
> primary. The purpose of this config is to ensure failover in case one of 
> the interfaces dies. This config usually works as expected.
>
> One scenario that doesn't work for us, is when link status of the active 
> slave is up, but all the packets sent to it are dropped, e.g., because of
> incorrect switch configuration. In that case bond failover doesn't happen. 
> Can this scenario be addressed with bonding?
>
> Thanks,
> Alex.
>
> I found a discussion, which looks relevant, labeled "How to check an 
> inactive slave in a bond?" in 
> http://www.spinics.net/lists/lartc/msg21434.html". But this discussion 
> considers the inactive slave, while in my case, I would like to better 
> handle problems with the active slave.
>
Hi Alex:

I don't understand your problem clearly, normally the fail_over_mac could 
work well, but in some strange situation, just like the active slave down 
and up, but
it could not work back again, can you explain your steps to reproduction the 
problem, I think I can meet the same problem?

Regards
Ding

> -- 
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>
