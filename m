From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH 3/3] bonding: Improve IGMP join processing
Date: Thu, 01 Mar 2007 13:58:33 -0800
Message-ID: <200703012158.l21LwX22001136@death.nxdomain.ibm.com>
References: <200703010103.l2113b22030905@death.nxdomain.ibm.com> <20070301164918.GA3199@gospo.rdu.redhat.com> <200703011705.l21H5Q22005750@death.nxdomain.ibm.com> <45E7289F.60406@hp.com> <20070301194305.GB3199@gospo.rdu.redhat.com>
Cc: Brian Haley <brian.haley@hp.com>, netdev@vger.kernel.org,
	bonding-devel@lists.sourceforge.net,
	Jeff Garzik <jgarzik@pobox.com>
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:50635 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030376AbXCAV6g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Mar 2007 16:58:36 -0500
Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l21LwaJG030451
	for <netdev@vger.kernel.org>; Thu, 1 Mar 2007 16:58:36 -0500
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by westrelay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l21Lwalr539792
	for <netdev@vger.kernel.org>; Thu, 1 Mar 2007 14:58:36 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l21LwZY3029198
	for <netdev@vger.kernel.org>; Thu, 1 Mar 2007 14:58:36 -0700
In-reply-to: <20070301194305.GB3199@gospo.rdu.redhat.com> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andy Gospodarek <andy@greyhouse.net> wrote:

>On Thu, Mar 01, 2007 at 02:25:19PM -0500, Brian Haley wrote:
[...]
>> So forgive my naive question, but what would it take to make IPv6 work? 
>>  I know DAD fails on a test setup I have, but I haven't dug-into why 
>> this is (I can guess), and I'd like to see it working.  I'm willing to 
>> help, even if just to get it limping along.
>> 
>
>Brian,
>
>If we are easily able to differentiate between the multicast addresses
>in the mc_list as to which are for ipv4 and which are for ipv6 then it
>would be easy to call-out to something in the ipv6 mcast code when
>needed instead of always calling out to ipv4 code.

	Which covers multicast (at least for the failover case; I think
the regular support is already pretty address-independent).

	Additionally, the IP address tracking for the ARP monitor
(bond_glean_dev_ip) needs IPv6 address support.  I seem to recall that
there's an issue with the slaves each getting separate link local
addresses automatically assigned, but I haven't fooled with that in a
while.  There are likely other problems that would crop up during
serious testing.

	A characterization of what the IPv6 related problems are would
be a good place to start; I would expect that active-backup mode without
arp_monitor shouldn't be too difficult to make operable.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
