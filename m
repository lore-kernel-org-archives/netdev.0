From: kuznet@ms2.inr.ac.ru
Subject: Re: shutdown() and SHUT_RD on TCP sockets - broken?
Date: Tue, 8 Jul 2003 21:03:07 +0400 (MSD)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200307081703.VAA13437@dub.inr.ac.ru>
References: <Mutt.LNX.4.44.0307090227050.9091-100000@excalibur.intercode.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mtk-lists@gmx.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jmorris@intercode.com.au (James Morris)
In-Reply-To: <Mutt.LNX.4.44.0307090227050.9091-100000@excalibur.intercode.com.au> from "James Morris" at éÀÌ 09, 2003 02:28:12 
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> blocks.  I see that this also occurs on FreeBSD 4.8, Tru64 5.1B,
> HP/UX 11 and Solaris 8.  Have I misunderstood Stevens,

Most likely, it is that rare case when Stevens forgot to check the statement.

>From viewpoint of TCP the behaviour described in Stevens' book
is highly unnatural. SHUT_RD on TCP does not make any sense.


> described here.  But, why do things happen in this way on Linux?

Actually, you could check one more thing. What does happen after freebsd 4.8
returns 0 on read()? Does it open window eventually?

As you checked, all the stacks ignore SHUT_RD, when receiving data
and queue it anyway. And when read()ing Linux and, apparently Solaris,
prefer to return this data.

Alexey
