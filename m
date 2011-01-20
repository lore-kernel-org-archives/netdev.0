From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [GIT] Networking
Date: Thu, 20 Jan 2011 14:21:43 -0800
Message-ID: <AANLkTikLY1B3=C2TjAbYKVHbub-aPeG2heaUBWRUAg=R@mail.gmail.com>
References: <20110119.180418.216749267.davem@davemloft.net>
 <AANLkTin32jUnBtHF-EAkSMnFQM6cTbn-G3NZQJ3xjTWU@mail.gmail.com> <1295559646.2613.35.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:33684 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752548Ab1ATWWg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Jan 2011 17:22:36 -0500
In-Reply-To: <1295559646.2613.35.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 20, 2011 at 1:40 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
> Then here ask for fd=3 both POLLIN and POLLOUT :
> kernel answers : OK for POLLOUT (not POLLIN), so previous poll() call
> was OK to be blocked after all...
>
> So I'm wondering if it could be a userland bug, that triggers with
> recent kernel changes.

As far as I can tell, that program isn't multi-threaded, and it should
not have returned to user land at all (no signal, and a restart). So I
think it's a kernel-only thing - there should have been nothing that
could have changed the poll list in user space. But I didn't really
check the threading status.

I'm trying to bisect it now to figure out more hints.

             Linus
