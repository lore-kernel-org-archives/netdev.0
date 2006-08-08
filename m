From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: bonding questions: "replaying" call to set_multicast_list and sending IGMP doing Fail-Over
Date: Tue, 08 Aug 2006 10:20:28 -0700
Message-ID: <200608081720.k78HKSZt020293@death.nxdomain.ibm.com>
References: <Pine.LNX.4.64.0608030815270.32510@zuben> <44D89A10.10701@voltaire.com>
Cc: netdev@vger.kernel.org, rdreier@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:36546 "EHLO
	e31.co.us.ibm.com") by vger.kernel.org with ESMTP id S965001AbWHHRVB
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Aug 2006 13:21:01 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e31.co.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k78HKllF025236
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Tue, 8 Aug 2006 13:20:53 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id k78HKUZp120764
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Tue, 8 Aug 2006 11:20:32 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k78HKU3n012935
	for <netdev@vger.kernel.org>; Tue, 8 Aug 2006 11:20:30 -0600
To: Or Gerlitz <ogerlitz@voltaire.com>
In-reply-to: <44D89A10.10701@voltaire.com> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Or Gerlitz <ogerlitz@voltaire.com> wrote:
[...]
>As i don't see any buffering of the IGMP packets, i understand there's no
>"reply" of sending them during fail-over and this means that only when the
>router would do IGMP query on this node it will learn on the fail-over. Is
>it indeed what's going on? if i understand correct it would take some
>meaningful time for the fail-over to be externally visible in this respect.

	As I recall, the intent is to keep switches up to date all the
time, so that there is no delay during a failover.  I.e., at every IGMP
query, the switch is answered on all possible ports.

>Also assuming it does exactly what the comment says, another issue i see
>here is that in the case of not only the active_slave being UP, the code
>would TX the IGMP packets over > 1 slave, and hence multicast packets
>would be sent by the switch also to ports "connected to" non-active
>slaves, something which will hurt the system performance!?

	I haven't studied the effects of having large amounts of
multicast traffic coming in under this situation.

	However, I would suspect that the MAC filters found on
sufficiently modern network adapters would drop the incoming multicast
traffic on the backup slaves, as only the active slave in active-backup
mode has its multicast list set.  That information is sent to a slave
when it becomes the active slave; see the call to bond_mc_swap() made by
bond_change_active_slave().

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
