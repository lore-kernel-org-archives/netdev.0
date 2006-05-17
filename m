From: "Christopher Friesen" <cfriesen@nortel.com>
Subject: Re: send(), sendmsg(), sendto() not thread-safe
Date: Wed, 17 May 2006 12:00:52 -0600
Message-ID: <446B64D4.6080301@nortel.com>
References: <20060517172557.43768.qmail@web51507.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zrtps0kn.nortel.com ([47.140.192.55]:64701 "EHLO
	zrtps0kn.nortel.com") by vger.kernel.org with ESMTP
	id S1750827AbWEQSA6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 May 2006 14:00:58 -0400
To: Benjamin Reed <br33d@yahoo.com>
In-Reply-To: <20060517172557.43768.qmail@web51507.mail.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Benjamin Reed wrote:

> I think Mark's point isn't about "atomic" writes;
> instead, he was pointing out that when a programmer
> reads that a call is thread-safe he usually
> understands that to mean that it does not need to be
> protected by a lock when used by multiple threads.

<snip>

> This thread-safe issue is an even bigger deal when you
> are sharing the socket amoung many independent
> processes since locking in that context is a bit
> harder and more inefficient than in a pthread context.

There have always been possible issues with concurrent access to 
sockets/fds.

Consider what happens if you share a socket between processes/threads, 
you call select() in both of them, then do a blocking recv() in both to 
receive the message.  One of them gets the message, and the other blocks 
unexpectedly.

Or consider calling lseek() from one task, while doing successive read() 
calls in the other.

Or imagine one thread doing recvmsg() with MSG_PEEK, then calling 
recvmsg() to get the data, but meanwhile another thread has already read 
the message.

The calls themselves are thread-safe, but the side-effects of them may 
lead to unexpected behaviour unless the designer enforces appropriate 
synchronization.

Chris
