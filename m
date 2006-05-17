From: Benjamin Reed <br33d@yahoo.com>
Subject: Re: send(), sendmsg(), sendto() not thread-safe
Date: Wed, 17 May 2006 10:25:57 -0700 (PDT)
Message-ID: <20060517172557.43768.qmail@web51507.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Return-path: <netdev-owner@vger.kernel.org>
Received: from web51507.mail.yahoo.com ([206.190.38.199]:13703 "HELO
	web51507.mail.yahoo.com") by vger.kernel.org with SMTP
	id S1750761AbWEQR2h (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 May 2006 13:28:37 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David et al, I think you may be missing the point. 

David S. Miller wrote:
> I don't understand why the desire is so high to
> ensure that individual threads get "atomic" writes,
> you can't even ensure that in the general case.

I think Mark's point isn't about "atomic" writes;
instead, he was pointing out that when a programmer
reads that a call is thread-safe he usually
understands that to mean that it does not need to be
protected by a lock when used by multiple threads.

With the current implementation of sendmsg it takes
some imagination to come up with scenario where it is
okay for concurrent sendmsg calls to mix their data.

> Only sloppy programs that don't do their own
internal
> locking hit into issues in this area.

You are looking at it backwards. If sendmsg were
indeed
thread-safe (two concurrent calls to sendmsg would not
mix their data), then it would be stupid for a
programmer to put a lock around the sendmsg call. It
would also be stupid for a programmer to protect a
call to socket() with a lock.

This thread-safe issue is an even bigger deal when you
are sharing the socket amoung many independent
processes since locking in that context is a bit
harder and more inefficient than in a pthread context.

So, if it isn't going to be "fixed". It would be nice
to at least document the issue. A cursory examination
of the sendmsg kernel code leads you to believe that
it is thread-safe in the sense that Mark is talking
about.

ben
