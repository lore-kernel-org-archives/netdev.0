From: "Chad N. Tindel" <chad@tindel.net>
Subject: Re: Wrong UIDs reported in /proc/net/tcp
Date: Fri, 19 Nov 2004 16:01:56 -0500
Message-ID: <20041119210156.GA6513@calma.pair.com>
References: <20041109205358.GA64015@calma.pair.com> <E1CRdBr-0001P2-00@gondolin.me.apana.org.au> <20041118190257.GA7084@calma.pair.com> <20041118210307.GA9557@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <20041118210307.GA9557@gondor.apana.org.au>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > OK, so just out of sheer morbid curiousity, I added an ioctl which will
> > accept 4 parameters (the address/port pairs), and will return the user id
> > associated with that socket.  I also changed pidentd to call this ioctl
> > instead of looking at /proc/net/tcp.  This should theoretically get rid
> > of all race conditions.
> 
> Please show us the code of your ioctl.

Hi-

I found the problem... it was a bug in my pidentd changes where I wasn't 
properly handling an ioctl failure.  So, using an ioctl to do a direct hash
table lookup makes the userid mismatches go away.  We've been running tests for
12 hours without any failures.

> Have you tried netlink yet? Does it exhibit the same problem?

Only so many test systems to go around.  ;-)  Will start these tests tonight
and report back.

Chad
