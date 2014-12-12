From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 v3] ip: Simplify executing ip cmd within
 network ns
Date: Thu, 11 Dec 2014 17:26:40 -0800
Message-ID: <20141211172640.1afc3283@urahara>
References: <1418337171-2792-1-git-send-email-vadim4j@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Vadim Kochan <vadim4j@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:49510 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755862AbaLLB0u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Dec 2014 20:26:50 -0500
Received: by mail-pd0-f172.google.com with SMTP id y13so6141770pdi.3
        for <netdev@vger.kernel.org>; Thu, 11 Dec 2014 17:26:50 -0800 (PST)
In-Reply-To: <1418337171-2792-1-git-send-email-vadim4j@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 12 Dec 2014 00:32:51 +0200
Vadim Kochan <vadim4j@gmail.com> wrote:

> +
> +#define NETNS_RUN_DIR "/var/run/netns"
> +#define NETNS_ETC_DIR "/etc/netns"
> +
> +#ifndef CLONE_NEWNET
> +#define CLONE_NEWNET 0x40000000	/* New network namespace (lo, device, names sockets, etc) */
> +#endif
> +
> +#ifndef MNT_DETACH
> +#define MNT_DETACH	0x00000002	/* Just detach from the tree */
> +#endif /* MNT_DETACH */
> +
> +/* sys/mount.h may be out too old to have these */
> +#ifndef MS_REC
> +#define MS_REC		16384
> +#endif
> +
> +#ifndef MS_SLAVE
> +#define MS_SLAVE	(1 << 19)
> +#endif
> +
> +#ifndef MS_SHARED
> +#define MS_SHARED	(1 << 20)
> +#endif
> +
> +extern int netns_switch(char *netns);
> +

Maybe it would be cleaner to introduce a new file netns.h
with this and the setnetns syscall wrapper
