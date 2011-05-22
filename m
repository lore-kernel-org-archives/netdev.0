From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: More prefetch fall-out
Date: Sun, 22 May 2011 11:38:44 -0700
Message-ID: <BANLkTimQAhP17Hg6D84gtCO3nJ_SSsDAeg@mail.gmail.com>
References: <BANLkTi=YwLaoTVjKguH-uZpZgXduLhiTNg@mail.gmail.com> <1306088626.12435.27.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:36545 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752141Ab1EVSjN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 May 2011 14:39:13 -0400
Received: from mail-ey0-f174.google.com (mail-ey0-f174.google.com [209.85.215.174])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id p4MId7ec007673
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=FAIL)
	for <netdev@vger.kernel.org>; Sun, 22 May 2011 11:39:08 -0700
Received: by eyx24 with SMTP id 24so1617333eyx.19
        for <netdev@vger.kernel.org>; Sun, 22 May 2011 11:39:04 -0700 (PDT)
In-Reply-To: <1306088626.12435.27.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, May 22, 2011 at 11:23 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
> Taking a look at various skb_queue_walk* call sites, I think prefetches
> are not a clear win, I would just remove them all from skbuff.h

Hmm.

I did that, and it turns out that we also have:

 - *lots* of network drivers that use "prefetch" (without including prefetch.h)
 - net/netlabel/netlabel_addrlist.h doing the same.

and fixing that up is annoying "grunt work".

So for now, I think I'll just do the "add the <linux/prefetch.h> to
<linux/skbuff.h>" thing, and leave networking alone. That makes
everything compile ("allyesconfig") even with my "you *have* to
include <linux/prefetch.h>" test-patch.

                                 Linus
