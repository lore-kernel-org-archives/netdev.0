From: David Stevens <dlstevens@us.ibm.com>
Subject: RE: Multicast problem
Date: Tue, 16 Oct 2007 12:46:00 -0700
Message-ID: <OF169A6A3A.47A4FACF-ON88257376.006C1CEA-88257376.006C7CC8@us.ibm.com>
References: <002501c8101a$6005dc10$04ac10ac@Jocke>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: "'Netdev'" <netdev@vger.kernel.org>, netdev-owner@vger.kernel.org
To: "Joakim Tjernlund" <joakim.tjernlund@transmode.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:57813 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933422AbXJPTqQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Oct 2007 15:46:16 -0400
In-Reply-To: <002501c8101a$6005dc10$04ac10ac@Jocke>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> dev_mcast and igmp looks:
> root@Challenger:/proc/net# m dev_mcast
> 1    eth0            1     0     01005e000001
> 2    eth1            1     0     01005e000001

        These are the hardware multicast addresses for
224.0.0.1 (so, correct).

> root@Challenger:/proc/net# m igmp
> Idx     Device    : Count Querier       Group    Users Timer    Reporter
> 1       eth0      :     1      V3
>                                 E0000001     1 0:00000000 0
> 2       eth1      :     1      V2
>                                 E0000001     1 0:00000000 0
> 4       lo        :     0      V3
>                                 E0000001     1 0:00000000 0

        ...and these are the group memberships for 224.0.0.1, so
also correct. This should receive and answer pings to 224.0.0.1
as long as you don't have ICMP set to ignore broadcasts. You should
not need to put the device in promiscuous mode for a ping of
224.0.0.1 to work, so if you do, then you have a driver, device
or switch problem.
        None of these interfaces have memberships in the OSPF groups,
so if you had OSPF running when you did this, it didn't join.

                                                        +-DLS

