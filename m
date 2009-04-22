From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] LSM: Add security_socket_post_accept() and
 security_socket_post_recv_datagram().
Date: Tue, 21 Apr 2009 23:34:03 -0700 (PDT)
Message-ID: <20090421.233403.83067664.davem@davemloft.net>
References: <20090422015228.GA13312@bx9.net>
	<20090421.212342.235921625.davem@davemloft.net>
	<20090422061006.GB27688@bx9.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: penguin-kernel@i-love.sakura.ne.jp, paul.moore@hp.com,
	linux-security-module@vger.kernel.org, netdev@vger.kernel.org
To: greg@blekko.com
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20090422061006.GB27688@bx9.net>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Greg Lindahl <greg@blekko.com>
Date: Tue, 21 Apr 2009 23:10:06 -0700

> On Tue, Apr 21, 2009 at 09:23:42PM -0700, David Miller wrote:
> 
>> I said explicitly that hard errors are allows (out of file
>> descriptors, memory allocation failure)
> 
> I have no idea what you meant by a "hard" error. Note that I also
> discussed EAGAIN, which appears to happen commonly historically and
> today, and appears to be what the security module folks would want to
> have happen and you're rejecting. Do you consider that to be a hard
> error? I'm betting not.

People use poll() to avoid -EAGAIN and blocking, they expect the bits
to tell them what fd's they can work on to do real work.

But this whole task_struct based security is bogus from the start.

If I dup a file descriptor for a listening socket, and accept() in the
"wrong" task, the other task has no way to accept() that connection
even if it's security settings allow it.  The connection is lost
forever.

The realm of file descriptors overlaps that of tasks.  Trying to
pretend this isn't the case results in all kinds of crazy things like
we see being attempted here.

I consider TOMOYO conceptually broken in many regards.
