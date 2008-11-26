From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Fix soft lockups/OOM issues w/ unix garbage collector
Date: Tue, 25 Nov 2008 21:19:13 -0800 (PST)
Message-ID: <20081125.211913.114802735.davem@davemloft.net>
References: <20081120220326.GE24416@ldl.fc.hp.com>
	<20081125231712.GA30297@ldl.fc.hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eteo@redhat.com
To: dannf@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45258
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754177AbYKZFTO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Nov 2008 00:19:14 -0500
In-Reply-To: <20081125231712.GA30297@ldl.fc.hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: dann frazier <dannf@hp.com>
Date: Tue, 25 Nov 2008 16:17:13 -0700

> -void unix_gc(void)
> +void wait_for_unix_gc(void)
>  {
> -	static bool gc_in_progress = false;
> +	int error;
> +
> +	do {
> +		error = wait_event_interruptible(unix_gc_wait,
> +						 gc_in_progress == false);
> +	} while(error);
> +}

If you want a truly uninterruptible wait, simply use wait_event().

Could you make this change and resubmit your patch?

Thanks Dann!
