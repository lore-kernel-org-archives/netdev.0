From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] Fix deadlock between boomerang_interrupt and
 boomerang_start_tx in 3c59x
Date: Wed, 11 Aug 2010 12:09:00 -0400
Message-ID: <20100811120900.3629706c@s6510>
References: <20100811151257.GB23317@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:48852 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754171Ab0HKQJF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Aug 2010 12:09:05 -0400
In-Reply-To: <20100811151257.GB23317@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 11 Aug 2010 11:12:57 -0400
Neil Horman <nhorman@tuxdriver.com> wrote:

> If netconsole is in use, there is a possibility for deadlock in 3c59x between
> boomerang_interrupt and boomerang_start_xmit.  Both routines take the vp->lock,
> and if netconsole is in use, a pr_* call from the boomerang_interrupt routine
> will result in the netconsole code attempting to trnasmit an skb, which can try
> to take the same spin lock, resulting in de

I thought we agreed that any device supporting netconsole agrees
to not call printk in the transmit path. Just kill the pr_* call.
