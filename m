From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Add a SOCK_DESTROY operation to close sockets from userspace
Date: Tue, 17 Nov 2015 20:04:53 -0800
Message-ID: <1447819493.22599.137.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1447811024-8553-1-git-send-email-lorenzo@google.com>
	 <20151117192738.365145d7@samsung9>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Lorenzo Colitti <lorenzo@google.com>, netdev@vger.kernel.org,
	edumazet@google.com, ek@google.com, maze@google.com,
	dtor@google.com
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:34560 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751029AbbKREE4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2015 23:04:56 -0500
Received: by padhx2 with SMTP id hx2so30624165pad.1
        for <netdev@vger.kernel.org>; Tue, 17 Nov 2015 20:04:55 -0800 (PST)
In-Reply-To: <20151117192738.365145d7@samsung9>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-11-17 at 19:27 -0800, Stephen Hemminger wrote:

> I understand why you might want this, but it smells like the same
> kind of problems that the "forced unmount" patch had which eventually
> led to it not being accepted in mainline.  Lots of corner
> cases and race conditions waiting to blow up.

Well, disconnecting a TCP socket seems straightforward, once you get a
sk pointer.

Code looks good.

> 
> Look at the issues that the multi-thread socket close has.
> This looks worse.

I do not see a problem here. A RST packet has roughly same effect, and
we do process them.

Cookies are 64bits and uniquely identify a socket.

Once you make sure the request comes from a privileged user, we are
good.

This user could easily install some iptables rules to generate RST
packets anyway.
