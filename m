From: Cheng Jin <chengjin@cs.caltech.edu>
Subject: Re: TCP receiver's window calculation problem
Date: Thu, 24 Jun 2004 12:18:19 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0406241209280.1272-100000@orchestra.cs.caltech.edu>
References: <Pine.NEB.4.33.0406241301010.28506-100000@dexter.psc.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "netdev@oss.sgi.com" <netdev@oss.sgi.com>,
        "fast-support@cs.caltech.edu" <fast-support@cs.caltech.edu>
Return-path: <netdev-bounce@oss.sgi.com>
To: John Heffner <jheffner@psc.edu>
In-Reply-To: <Pine.NEB.4.33.0406241301010.28506-100000@dexter.psc.edu>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi, John,

Thanks for confirming this problem.

> I've run in to this problem, too.  This code prevents advertising more
> rcvbuf space than you are likely to need.  This is good for something like
> an X11 connection, but obviously very bad for the bulk transfer mixed MTU

I would think this is already taken care of at the sender by application
limited cwnd so cwnd wouldn't increase beyond what is being actually used.

> I think the most desirable answer is to not have a hard per-connection
> memory bound, but this is problematic because of denial-of-service
> conerns.

I think having a default limit on tcp memory is acceptable to prevent DoS, 
but when a user increases the memory limit by explicitly setting tcp_rmem,
that should take effect.  The code itself shouldnt pose any limit like it 
does now.

Actually, I am not clear what that window-calculation algorithm is.  Is it 
recommended by some RFC?

Cheng
