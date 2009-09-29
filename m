From: Christian Borntraeger <borntraeger@de.ibm.com>
Subject: Re: [PATCH] connector: Fix sid connector (was: Badness at kernel/softirq.c:143...)
Date: Tue, 29 Sep 2009 16:15:38 +0200
Message-ID: <200909291615.38457.borntraeger@de.ibm.com>
References: <200909251123.03482.borntraeger@de.ibm.com> <200909291547.21528.borntraeger@de.ibm.com> <20090929140718.GA23858@ioremap.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Oleg Nesterov <oleg@redhat.com>,
	Evgeny Polyakov <johnpol@2ka.mipt.ru>,
	Scott James Remnant <scott@ubuntu.com>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	Matt Helsley <matthltc@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.uk.ibm.com ([195.212.29.139]:34371 "EHLO
	mtagate6.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752454AbZI2OQC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Sep 2009 10:16:02 -0400
In-Reply-To: <20090929140718.GA23858@ioremap.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Dienstag 29 September 2009 16:07:18 schrieb Evgeniy Polyakov:
> Your patch breaks assumption that task_session(current->group_leader) is
> not equal to new session id, but to check task_session() we need either
> rcu or task lock. Also setsid() return value is not zero or negative
> error, but new session ID or negative error,

Right.

> so I believe attached patch is a proper fix, although it looks rather ugly.
> 
> Also proc_sid_connector() uses GFP_KERNEL allocation which is way too
> wrong to use under any locks.
> 
> Something like this (not tested :)

Patch compiles and seems to work.

Christian
