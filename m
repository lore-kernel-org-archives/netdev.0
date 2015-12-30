From: Andy Lutomirski <luto@kernel.org>
Subject: Linux 4.4-rc4 regression, bisected to "net: fix sock_wake_async() rcu protection"
Date: Wed, 30 Dec 2015 03:18:11 -0800
Message-ID: <CALCETrUHFDdfPymKfD2TJHL6w-C5dc675xuJfk=c=-twsPZqqA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Dmitry Vyukov <dvyukov@google.com>,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:37172 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754253AbbL3LSd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Dec 2015 06:18:33 -0500
Received: from mail.kernel.org (localhost [127.0.0.1])
	by mail.kernel.org (Postfix) with ESMTP id 2F2D720304
	for <netdev@vger.kernel.org>; Wed, 30 Dec 2015 11:18:32 +0000 (UTC)
Received: from mail-oi0-f45.google.com (mail-oi0-f45.google.com [209.85.218.45])
	(using TLSv1.2 with cipher AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 77398202EC
	for <netdev@vger.kernel.org>; Wed, 30 Dec 2015 11:18:31 +0000 (UTC)
Received: by mail-oi0-f45.google.com with SMTP id o124so200504288oia.1
        for <netdev@vger.kernel.org>; Wed, 30 Dec 2015 03:18:31 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On recent v4.4-rc releases, I can't run emacs.  No, really, running
"emacs" in a GNOME 3 session makes gnome-shell think that emacs is
running, but no window is drawn, and the overall system UI is a bit
weird when the invisible emacs window is focused.

This is 100% reproducible.

There might be other symptoms involving gdb malfunctioning, but those
are, at best, sporadic.  The emacs failure is entirely reliable.  I
have no idea what the underlying failure mode is, but failure to wake
a socket waiter seems plausible,  I also have no idea why oocalc,
gimp, vim, gedit, firefox, etc aren't affected.

A somewhat unorthodox "git bisect" run blames:

commit ceb5d58b217098a657f3850b7a2640f995032e62
Author: Eric Dumazet <edumazet@google.com>
Date:   Sun Nov 29 20:03:11 2015 -0800

    net: fix sock_wake_async() rcu protection

I've confirmed that v4.4-rc7 with that patch reverted works fine.

Since the offending commit was apparently a security fix, simply
reverting it might not be the best idea.

--Andy
