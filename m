From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Fw: iproute2 showing wrong number of bytes on 64bit architectures.
Date: Tue, 10 Jul 2007 08:56:40 -0700
Message-ID: <20070710085640.128311d1@freepuppy.rosehill.hemminger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:34577 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753110AbXGJP4o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jul 2007 11:56:44 -0400
Received: from freepuppy.rosehill.hemminger.net (069-064-229-129.pdx.net [69.64.229.129])
	(authenticated bits=0)
	by smtp2.linux-foundation.org (8.13.5.20060308/8.13.5/Debian-3ubuntu1.1) with ESMTP id l6AFufQG001386
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Tue, 10 Jul 2007 08:56:43 -0700
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Looks like net_device_stats should have always used u32?
Too late to change it now.

Begin forwarded message:

Date: Tue, 10 Jul 2007 13:58:51 +0200
From: Andreas Henriksson <andreas@fatal.se>
To: netdev@vger.kernel.org
Cc: 199054@bugs.debian.org
Subject: iproute2 showing wrong number of bytes on 64bit architectures.


Hello!

While investigating the problems reported in Debian bug #199054
(http://bugs.debian.org/199054), stating that the RX/TX bytes differ between
ifconfig and ip(route2) I came across this:

include/linux/if_link.h (used in kernel and iproute2 source):
/* The struct should be in sync with struct net_device_stats */
struct rtnl_link_stats
{
	__u32 ...;
	__u32 ...;
	__u32 ...;
	__u32 ...;
...


include/linux/netdevice.h:
struct net_device_stats
{
	unsigned long   ...;
	unsigned long   ...;
	unsigned long   ...;
	unsigned long   ...;
	unsigned long   ...;
....


This will be a problem when unsigned long isn't 32bits, but I guess the
rtnetlink message size is static for good reason. 
Can someone please advise on how to fix this?

-- 
Regards,
Andreas Henriksson
-
To unsubscribe from this list: send the line "unsubscribe netdev" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html


-- 
Stephen Hemminger <shemminger@linux-foundation.org>
