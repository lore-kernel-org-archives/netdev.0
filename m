From: Sebastian Siewior <netdev@ml.breakpoint.cc>
Subject: Re: [PATCH / RFC 0/2] spinlocks fixup in fec / m68knommu driver
Date: Wed, 2 Apr 2008 13:11:12 +0200
Message-ID: <20080402111112.GA11054@Chamillionaire.breakpoint.cc>
References: <20080327140041.072611004@linutronix.de> <47EDA791.4090402@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: Sebastian Siewior <bigeasy@linutronix.de>, uclinux-dev@uclinux.org,
	netdev@vger.kernel.org, Greg Ungerer <gerg@uclinux.org>
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:39367 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753218AbYDBLLY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Apr 2008 07:11:24 -0400
Content-Disposition: inline
In-Reply-To: <47EDA791.4090402@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Jeff Garzik | 2008-03-28 22:21:05 [-0400]:

> Sebastian Siewior wrote:
>> I got into this after turning on spinlock debugging.
>> Jeff: The dev->hard_start_xmit callback is always called from softirq
>> context so it is save to use spin_lock_irq(), right?
>> Greg: The isr (fec_enet_rx()) calls three functions. All
>> but fec_enet_rx() are grabbing the spinlock. Is this on purpose?

Jeff please drop that one, I form a new patch just located another BUG.
That one triggers on high load on a non-smp, non-preempt machine.

Sebastian
