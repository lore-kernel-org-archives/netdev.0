From: David Miller <davem@davemloft.net>
Subject: Re: use-after-free in usbnet
Date: Sat, 21 Apr 2012 15:23:45 -0400 (EDT)
Message-ID: <20120421.152345.290988116097275353.davem@davemloft.net>
References: <CACVXFVM5YBJkDZddeGi1_MPY7EqEV_wtoFy-NtBHYA6rxez0jg@mail.gmail.com>
	<CA+v9cxZWtGbz6uCSysVbAc1hT27rCiuJXzcvSiTxH-zuQYnrZw@mail.gmail.com>
	<CACVXFVOc0XZ+eLHGiVwKuiUResRk8Cj9MS4EPMx7k57a0tEJhA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: huajun.li.lee@gmail.com, oneukum@suse.de,
	stern@rowland.harvard.edu, davej@redhat.com,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	kernel-team@fedoraproject.org
To: tom.leiming@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:43339 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750911Ab2DUTYL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Apr 2012 15:24:11 -0400
In-Reply-To: <CACVXFVOc0XZ+eLHGiVwKuiUResRk8Cj9MS4EPMx7k57a0tEJhA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ming Lei <tom.leiming@gmail.com>
Date: Sat, 21 Apr 2012 09:49:51 +0800

> I see the problem, so looks skb_queue_walk_safe is not safe.
> I don' know why the 2nd ' tmp = skb->next' in  skb_queue_walk_safe
> is needed and it may become unsafe if skb is freed during current loop.

I can't see what the problem is, skb_queue_walk_safe() is perfect
and does exactly what it advertises to do.

If 'skb' is unlinked inside of an skb_queue_walk_safe() loop, that's
fine, because we won't touch 'skb' in the loop iteration tail code.

Instead, before the loop contents, we pre-fetch skb->next into 'tmp'
and then at the end we move 'skb' forward by simply assigning 'tmp'.
