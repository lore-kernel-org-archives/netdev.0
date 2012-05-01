From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: add a prefetch in socket backlog
 processing
Date: Tue, 01 May 2012 14:29:11 +0200
Message-ID: <1335875351.11396.55.camel@edumazet-glaptop>
References: <1335838029.11396.12.camel@edumazet-glaptop>
	 <1335842663.26217.10.camel@joe2Laptop>
	 <1335854091.11396.21.camel@edumazet-glaptop>
	 <1335873153.26217.35.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:34238 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755901Ab2EAM3S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 May 2012 08:29:18 -0400
Received: by bkcji2 with SMTP id ji2so903171bkc.19
        for <netdev@vger.kernel.org>; Tue, 01 May 2012 05:29:16 -0700 (PDT)
In-Reply-To: <1335873153.26217.35.camel@joe2Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-05-01 at 04:52 -0700, Joe Perches wrote:

> That's true for cpus with sufficient cache but prefetch
> might be wasteful for cpus without (like some ARMs).
> 

> Some of the sk_backlog_rcv functions like tcp_v4_do_rcv
> can be relatively large.

You speak of icache here. Thats different matter.

My patch does a prefetch of data (dcache)

> 
> It might be useful to have a target cpu compile time
> test precede this prefetch.

How this prefetch() is different than other ones in kernel ?

We optimize linux for cpus with a minimum cache, not for the ones with
less than 16KB caches.

For old cpus, you can use linux 2.4 it works much better.

If you believe there is an issue on a particular arch, I suggest you
talk with arch maintainer about ARCH_HAS_PREFETCH being undefined on
this arch.
