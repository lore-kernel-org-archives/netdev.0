From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: BUG: soft lockup detected on CPU#0!  (2.6.18.2 plus hacks)
Date: Wed, 3 Jan 2007 09:07:11 +0100
Message-ID: <20070103080711.GA1747@ff.dom.local>
References: <4599E6D5.6050207@candelatech.com> <OFB8CE3E37.99FD5849-ON88257257.0080FAE8-88257257.00819B15@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Greear <greearb@candelatech.com>,
	NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:52181 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755004AbXACIFe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Jan 2007 03:05:34 -0500
To: David Stevens <dlstevens@us.ibm.com>
Content-Disposition: inline
In-Reply-To: <OFB8CE3E37.99FD5849-ON88257257.0080FAE8-88257257.00819B15@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 02, 2007 at 03:35:39PM -0800, David Stevens wrote:
> I've looked at this a little too -- it'd be nice to know who holds
> the write lock.

If you mean mc_list_lock - probably nobody - it's
not initialized (so the timers) for this in_device
and rtnl mutex is preempted by irq.

Actually I wonder if lockdep isn't masking (or even
spoiling) something, so I'd try with:
"Lock debugging: ..." options off
(CONFIG_DEBUG_SPINLOCK = y
CONFIG_DEBUG_LOCK_ALLOC = n).

Jarek P. 

PS: because of unknown changes from those patches
this is guessing only.
