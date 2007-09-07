From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH] bonding: update some distro-specific documentation
Date: Fri, 07 Sep 2007 11:27:49 -0700
Message-ID: <21001.1189189669@death>
References: <20070830212429.GA12676@gospo.rdu.redhat.com>
Cc: netdev@vger.kernel.org
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:49858 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757676AbXIGS2L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Sep 2007 14:28:11 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l87IRvHQ012489
	for <netdev@vger.kernel.org>; Fri, 7 Sep 2007 14:27:57 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l87IRuob429520
	for <netdev@vger.kernel.org>; Fri, 7 Sep 2007 12:27:56 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l87IRtkh030970
	for <netdev@vger.kernel.org>; Fri, 7 Sep 2007 12:27:55 -0600
In-reply-to: <20070830212429.GA12676@gospo.rdu.redhat.com> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andy Gospodarek <andy@greyhouse.net> wrote:

	This all looks fine except for one nit (well, request for extra
detail, really):

>@@ -802,15 +802,20 @@ BROADCAST=192.168.1.255
> ONBOOT=yes
> BOOTPROTO=none
> USERCTL=no
>+BONDING_OPTS="mode=balance-alb miimon=100"
>
> 	Be sure to change the networking specific lines (IPADDR,
> NETMASK, NETWORK and BROADCAST) to match your network configuration.
>+You also need to set the BONDING_OPTS= line to specify the desired
>+options for your bond0 interface.  Specifying bonding options in this
>+way is the preferred method for configuring bonding interfaces.

	Can you add something here that mentions that, for the
arp_ip_target option, it has to be supplied as "arp_ip_target=+10.0.0.1"
and not just "arp_ip_target=10.0.0.1"?  Also, multiple targets require
multiple instances of the arp_ip_target option; it doesn't work to put
multiple IP addresses as in the module option (i.e.,
"arp_ip_target=10.0.0.1,10.0.0.2").

	This is necessary because ifup-eth isn't adding the "+" when it
translates the option for use with sysfs or parsing the multiple IP
address syntax.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
