From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] LSM: Add security_socket_post_accept() and
 security_socket_post_recv_datagram().
Date: Tue, 21 Apr 2009 05:37:01 -0700 (PDT)
Message-ID: <20090421.053701.234331700.davem@davemloft.net>
References: <200904212039.JID59468.LOFOtMQOFJFSVH@I-love.SAKURA.ne.jp>
	<20090421.044053.155783771.davem@davemloft.net>
	<200904212126.AJD95821.HFMOFtQJOVFLOS@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paul.moore@hp.com, linux-security-module@vger.kernel.org,
	netdev@vger.kernel.org
To: penguin-kernel@I-love.SAKURA.ne.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41103
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751383AbZDUMhN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Apr 2009 08:37:13 -0400
In-Reply-To: <200904212126.AJD95821.HFMOFtQJOVFLOS@I-love.SAKURA.ne.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Tue, 21 Apr 2009 21:26:36 +0900

> It is too late to modify because we have already accepted the
> packet.

Then queue it up somewhere, and deliver your verdict and continue
packet processing later.

In fact, I do not like killing accept()'s like this at all.

If we tell the application, via poll() or similar, that connections
are available and no other thread can get in there to steal the
connection, we must deliver a connection to the listening socket when
it calls accept() except in very unusual circumstances (out of file
descriptors, memory allocation failure, etc.)!

I believe this idea is conceptually very broken, sorry.  The semantics
are absolutely horrible.

Put this stuff in userspace, where you say it already is.  The kernel
isn't the place to dump every cool feature you want to bring in from
userspace.
