From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] dev: use name hash for dev_seq_ops
Date: Thu, 20 Oct 2011 16:17:41 -0400 (EDT)
Message-ID: <20111020.161741.1961240945982687125.davem@davemloft.net>
References: <1319097717-14910-1-git-send-email-mmaruseac@ixiacom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, eric.dumazet@gmail.com,
	mirq-linux@rere.qmqm.pl, therbert@google.com, jpirko@redhat.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	dbaluta@ixiacom.com, mmaruseac@ixiacom.com
To: mihai.maruseac@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1319097717-14910-1-git-send-email-mmaruseac@ixiacom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mihai Maruseac <mihai.maruseac@gmail.com>
Date: Thu, 20 Oct 2011 11:01:57 +0300

> Instead of using the dev->next chain and trying to resync at each call to
> dev_seq_start, use the name hash, keeping the bucket and the offset in
> seq->private field.

I'm totally fine with this patch from a technical perspective, but I'd
like one small thing tidied up before I apply this.

> +	unsigned int pos; /* bucket << 24 + offset */

Please don't mention this as a constant in the comment, if we ever
change NETDEV_HASHBITS this comment will be inaccurate.

I'd suggest putting the BUCKET_SPACE define before the dev_iter_state
definition, and using BUCKET_SPACE in the comment instead of 24.

Thanks.
