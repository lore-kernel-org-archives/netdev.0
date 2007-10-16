From: "Joakim Tjernlund" <joakim.tjernlund@transmode.se>
Subject: RE: Multicast problem
Date: Tue, 16 Oct 2007 22:07:35 +0200
Message-ID: <002701c81030$31908a90$04ac10ac@Jocke>
References: <OF169A6A3A.47A4FACF-ON88257376.006C1CEA-88257376.006C7CC8@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "'Netdev'" <netdev@vger.kernel.org>
To: "'David Stevens'" <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.transmode.se ([83.241.175.147]:46139 "EHLO
	tmnt04.transmode.se" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S933827AbXJPUHj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Oct 2007 16:07:39 -0400
In-Reply-To: <OF169A6A3A.47A4FACF-ON88257376.006C1CEA-88257376.006C7CC8@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: David Stevens [mailto:dlstevens@us.ibm.com] 
> Sent: den 16 oktober 2007 21:46
> To: Joakim Tjernlund
> Cc: 'Netdev'; netdev-owner@vger.kernel.org
> Subject: RE: Multicast problem
> 
> > dev_mcast and igmp looks:
> > root@Challenger:/proc/net# m dev_mcast
> > 1    eth0            1     0     01005e000001
> > 2    eth1            1     0     01005e000001
> 
>         These are the hardware multicast addresses for
> 224.0.0.1 (so, correct).
> 
> > root@Challenger:/proc/net# m igmp
> > Idx     Device    : Count Querier       Group    Users 
> Timer    Reporter
> > 1       eth0      :     1      V3
> >                                 E0000001     1 0:00000000 0
> > 2       eth1      :     1      V2
> >                                 E0000001     1 0:00000000 0
> > 4       lo        :     0      V3
> >                                 E0000001     1 0:00000000 0
> 
>         ...and these are the group memberships for 224.0.0.1, so
> also correct. This should receive and answer pings to 224.0.0.1
> as long as you don't have ICMP set to ignore broadcasts. You should
> not need to put the device in promiscuous mode for a ping of
> 224.0.0.1 to work, so if you do, then you have a driver, device
> or switch problem.
>         None of these interfaces have memberships in the OSPF groups,
> so if you had OSPF running when you did this, it didn't join.
> 
>                                                         +-DLS
> 

OK, so from all this and earlier mail I think that the device driver don't
receive multicast pkgs. Tomorrow I will try the real OSPF test case with
promisc mode enabled, se if that works. If so, it means there is
a bug in the drivers(ucc_geth.c) set_multicast_list() function.

Thank you for helping me to narrow it down.

 Jocke

