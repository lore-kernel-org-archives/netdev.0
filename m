From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH 3/3] bonding: Improve IGMP join processing
Date: Tue, 06 Mar 2007 12:39:17 -0800
Message-ID: <22603.1173213557@death>
References: <200703010103.l2113b22030905@death.nxdomain.ibm.com> <20070301164918.GA3199@gospo.rdu.redhat.com> <200703011705.l21H5Q22005750@death.nxdomain.ibm.com> <45E7289F.60406@hp.com> <20070301194305.GB3199@gospo.rdu.redhat.com> <45EDC730.40007@hp.com>
Cc: Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org,
	bonding-devel@lists.sourceforge.net
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:54490 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932166AbXCFUj1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Mar 2007 15:39:27 -0500
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l26KdP9b029746
	for <netdev@vger.kernel.org>; Tue, 6 Mar 2007 15:39:25 -0500
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l26KdPaH117468
	for <netdev@vger.kernel.org>; Tue, 6 Mar 2007 15:39:25 -0500
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l26KdOtW004792
	for <netdev@vger.kernel.org>; Tue, 6 Mar 2007 15:39:25 -0500
In-reply-to: <45EDC730.40007@hp.com> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Brian Haley <brian.haley@hp.com> wrote:

>Andy Gospodarek wrote:
>> If we are easily able to differentiate between the multicast addresses
>> in the mc_list as to which are for ipv4 and which are for ipv6 then it
>> would be easy to call-out to something in the ipv6 mcast code when
>> needed instead of always calling out to ipv4 code.
>
>I've been unable to figure out exactly what you're referring to in the
>code (bond_main.c), it seems to failover all multicast addresses,
>regardless of what address family they are.  I might have missed something
>in 4K lines of code though?

	I believe Andy is talking about bond_resend_igmp_join_requests
being only effective for IGMP v4 and not IGMP v6.  The reason being that
there is (a) no discrimination between v4 and v6 multicast addresses,
and (b) for the v6 case, there's no "rejoin" type function as was
created for IPv4 with the patch.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
