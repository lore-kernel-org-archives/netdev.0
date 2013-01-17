From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sk-filter: Add ability to lock a socket
 filter program
Date: Thu, 17 Jan 2013 03:33:34 -0500 (EST)
Message-ID: <20130117.033334.409124726853704397.davem@davemloft.net>
References: <20130116.162012.1782638746075880444.davem@davemloft.net>
	<1358373349-22326-1-git-send-email-bernat@luffy.cx>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: bernat@luffy.cx
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45657 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759234Ab3AQIdi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jan 2013 03:33:38 -0500
In-Reply-To: <1358373349-22326-1-git-send-email-bernat@luffy.cx>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vincent Bernat <bernat@luffy.cx>
Date: Wed, 16 Jan 2013 22:55:49 +0100

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

Looks good, applied, thanks Vincent.
