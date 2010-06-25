From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 2.6.35] bonding: prevent netpoll over bonded interfaces
Date: Sat, 26 Jun 2010 00:31:50 +0200
Message-ID: <87y6e2d9rd.fsf@basil.nowhere.org>
References: <20100625195044.GQ7497@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, amwang@redhat.com, fubar@us.ibm.com
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:33011 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751791Ab0FYWbw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jun 2010 18:31:52 -0400
In-Reply-To: <20100625195044.GQ7497@gospo.rdu.redhat.com> (Andy Gospodarek's
	message of "Fri, 25 Jun 2010 15:50:44 -0400")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andy Gospodarek <andy@greyhouse.net> writes:

> Support for netpoll over bonded interfaces was added here:
>
> 	commit f6dc31a85cd46a959bdd987adad14c3b645e03c1
> 	Author: WANG Cong <amwang@redhat.com>
> 	Date:   Thu May 6 00:48:51 2010 -0700
>
> 	    bonding: make bonding support netpoll
>
> but it is bad enough that we should probably just disable netpoll over
> bonding until some of the locking logic in the bonding driver is changed
> or converted completely to RCU.  Simple actions like changing the active
> slave in active-backup mode will hang the box if a high enough printk
> debugging level is enabled.

Normally you just need to prevent the printks when called from poll
context. That's not rocket science.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.
