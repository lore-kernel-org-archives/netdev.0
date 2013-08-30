From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] net/hsr: Add support for the High-availability
 Seamless Redundancy protocol (HSRv0)
Date: Fri, 30 Aug 2013 15:54:15 -0400 (EDT)
Message-ID: <20130830.155415.1756229438072680437.davem@davemloft.net>
References: <521504E1.5060309@xdin.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com, joe@perches.com,
	jboticario@gmail.com, balferreira@googlemail.com
To: arvid.brodin@xdin.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56790 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756060Ab3H3TyW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Aug 2013 15:54:22 -0400
In-Reply-To: <521504E1.5060309@xdin.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arvid Brodin <arvid.brodin@xdin.com>
Date: Wed, 21 Aug 2013 20:20:17 +0200

> This is a patch against net-next (2013-08-21).

First of all, your email client corrupted the patch, chopping up long lines
and making whitespace changes to the content of the patch.  Please fix this
before resubmitting, and do so by first sending a test patch to yourself
and making sure you can apply the patch you receive in that email.  Do not
use attachments to deal with this issue.

> +	if (dev->operstate != transition) {
> +		write_lock_bh(&dev_base_lock);
> +		dev->operstate = transition;
> +		write_unlock_bh(&dev_base_lock);
> +		netdev_state_change(dev);
> +	}

This is racy.  And it appears that set_operstate() in net/core/rtnetlink.c
has the same bug, I guess that's what you used as a guide.

Any "test and set" sequence must be guarded completely by the lock, it
doesn't make any sense to only guard the change of the value.
