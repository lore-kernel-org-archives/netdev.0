From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: More prefetch fall-out
Date: Sun, 22 May 2011 10:49:11 -0700
Message-ID: <BANLkTi=YwLaoTVjKguH-uZpZgXduLhiTNg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Network Development <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:51026 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753522Ab1EVRte (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 May 2011 13:49:34 -0400
Received: from mail-ey0-f174.google.com (mail-ey0-f174.google.com [209.85.215.174])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id p4MHnVrd005454
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=FAIL)
	for <netdev@vger.kernel.org>; Sun, 22 May 2011 10:49:33 -0700
Received: by eyx24 with SMTP id 24so1610441eyx.19
        for <netdev@vger.kernel.org>; Sun, 22 May 2011 10:49:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

So it turns out that the architectures that don't define their
prefetch() macros in <asm/processor.h> (and instead depend on
linux/prefetch.h to give them the default ones) are currently broken.

Fine, that's really trivial to fix. And, in fact, I'm now testing on
x86 by having x86 put its prefetch infrastructure in <asm/prefetch.h>
and thus making sure that you *have* to include <linux/prefetch.h> to
get it (rather than get it accidentally just because everything ends
up including <asm/processor.h>).

However, one of the breakages is <linux/skbuff.h> that does its own
list-walking functions ("skb_queue_walk*"), and they do prefetching.
So now I have the option to either just add <linux/prefetch.h> to that
file, or remove the prefetches. And you're the one that said that the
prefetches in the networking code were annoying.

So should the skb queues use prefetching? I have a hard time judging.
Are those lists usually long? Is the loop usually large enough that
there is any point to prefetching the next entry?

                         Linus
