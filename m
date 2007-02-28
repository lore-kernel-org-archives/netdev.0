From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH] bonding: make IGMP flooding on active-backup bonds configurable
Date: Wed, 28 Feb 2007 14:39:42 -0800
Message-ID: <200702282239.l1SMdg22017137@death.nxdomain.ibm.com>
References: <20070228222331.GA28813@gospo.rdu.redhat.com>
Cc: netdev@vger.kernel.org
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:56158 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750839AbXB1Wjr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Feb 2007 17:39:47 -0500
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l1SMdid4014036
	for <netdev@vger.kernel.org>; Wed, 28 Feb 2007 17:39:44 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l1SMdiZa216408
	for <netdev@vger.kernel.org>; Wed, 28 Feb 2007 17:39:44 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l1SMdiXO008950
	for <netdev@vger.kernel.org>; Wed, 28 Feb 2007 17:39:44 -0500
In-reply-to: <20070228222331.GA28813@gospo.rdu.redhat.com> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andy Gospodarek <andy@greyhouse.net> wrote:

>A while back the following change was made to the bonding code:
>
>commit df49898a47061e82219c991dfbe9ac6ddf7a866b
>Author: John W. Linville <linville@tuxdriver.com>
>Date:   Tue Oct 18 21:30:58 2005 -0400
>
>    [PATCH] bonding: cleanup comment for mode 1 IGMP xmit hack
>    
>    Expand comment explaining MAC address selection for replicated IGMP
>    frames transmitted in bonding mode 1 (active-backup).  Also, a small
>    whitespace cleanup.
>    
>    Signed-off-by: John W. Linville <linville@tuxdriver.com>
>    Signed-off-by: Jeff Garzik <jgarzik@pobox.com>
>
>In general this patch is good, but this tweaks that feature by allowing
>that functionality to be enabled and disabled.  This patch adds a new
>module option as well as a sysfs entry.  It sets the default to be the
>current behavior so existing users shouldn't notice any difference.

	Why would you want to turn this off?

	Also, I've got a replacement patch for this functionality that
seems to be better in all regards. It sends bonus IGMP joins when a
failover occurs, rather than simply duplicating them on all slaves (the
current system can leave switches in the dark if the slaves fail back to
the originals).  As chance would have it, I'm planning to post it as
part of a set in a a little while.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
