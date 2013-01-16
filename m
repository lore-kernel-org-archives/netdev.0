From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sk-filter: Add ability to lock a socket filter program
Date: Wed, 16 Jan 2013 16:20:12 -0500 (EST)
Message-ID: <20130116.162012.1782638746075880444.davem@davemloft.net>
References: <1358296955-30582-1-git-send-email-bernat@luffy.cx>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: bernat@luffy.cx
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39350 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755989Ab3APVUO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jan 2013 16:20:14 -0500
In-Reply-To: <1358296955-30582-1-git-send-email-bernat@luffy.cx>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vincent Bernat <bernat@luffy.cx>
Date: Wed, 16 Jan 2013 01:42:34 +0100

> While a privileged program can open a raw socket, attach some
> restrictive filter and drop its privileges (or send the socket to an
> unprivileged program through some Unix socket), the filter can still
> be removed or modified by the unprivileged program. This commit adds a
> socket option to lock the filter (SO_LOCK_FILTER) preventing any
> modification of a socket filter program.
> 
> This is similar to OpenBSD BIOCLOCK ioctl on bpf sockets, except even
> root is not allowed change/drop the filter.
> 
> The state of the lock can be read with getsockopt(). No error is
> triggered if the state is not changed. -EPERM is returned when a user
> tries to remove the lock or to change/remove the filter while the lock
> is active. The check is done directly in sk_attach_filter() and
> sk_detach_filter() and does not affect only setsockopt() syscall.
> 
> Signed-off-by: Vincent Bernat <bernat@luffy.cx>

I'm fine with this feature but:

> +SO_LOCK_FILTER ioctl allows to lock the filter attached to a

It's not an ioctl, it's a socket option.
