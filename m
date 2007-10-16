From: "Joakim Tjernlund" <joakim.tjernlund@transmode.se>
Subject: RE: Multicast problem
Date: Tue, 16 Oct 2007 19:31:24 +0200
Message-ID: <002501c8101a$6005dc10$04ac10ac@Jocke>
References: <OFB45E9AE1.F95FB289-ON88257376.005D25C3-88257376.005DB70D@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "'Netdev'" <netdev@vger.kernel.org>
To: "'David Stevens'" <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.transmode.se ([83.241.175.147]:42018 "EHLO
	tmnt04.transmode.se" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751631AbXJPRb2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Oct 2007 13:31:28 -0400
In-Reply-To: <OFB45E9AE1.F95FB289-ON88257376.005D25C3-88257376.005DB70D@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: David Stevens [mailto:dlstevens@us.ibm.com] 
> Sent: den 16 oktober 2007 19:05
> To: joakim.tjernlund@transmode.se
> Cc: Netdev
> Subject: Re: Multicast problem
> 
> If you have icmp_echo_ignore_broadcasts set to 1, it won't respond to
> multicasts. That should be all you need to do for 224.0.0.1.
> 
> Some smart switches rely on IGMP snooping to determine group 
> membership,
> and some of those don't understand IGMPv3, so if you have no v1 or v2 
> queriers
> on the network, you can force the IGMP version to be 2 instead of the 
> default 3
> by using a sysctl.

 Tried forcing igmp from 3 to 2, didn't help

> But that's not the issue for 224.0.0.1, since the 
> all-hosts group
> is not reported via IGMP.
> 
> You might check the contents of /proc/net/igmp and 
> /proc/net/dev_mcast to

dev_mcast and igmp looks:
root@Challenger:/proc/net# m dev_mcast
1    eth0            1     0     01005e000001
2    eth1            1     0     01005e000001

root@Challenger:/proc/net# m igmp
Idx     Device    : Count Querier       Group    Users Timer    Reporter
1       eth0      :     1      V3
                                E0000001     1 0:00000000               0
2       eth1      :     1      V2
                                E0000001     1 0:00000000               0
4       lo        :     0      V3
                                E0000001     1 0:00000000               0

I can't tell if that's OK or not.

 
> make
> sure they have entries for the group. If so, I'd guess it might be a 
> driver or device issue.

Could it be some missing kernel config? This is a custom board so I could
very well miss something I kernel config or user space config.

Thanks for your help, if you have any more ideas you are most welcome
to share :)

 Jocke
> 
>                                                         +-DLS

