From: Geoffrey Lee <glee@gnupilgrims.org>
Subject: Re: [PATCH] connect() return value.
Date: Mon, 12 Aug 2002 09:25:46 +1000
Sender: owner-netdev@oss.sgi.com
Message-ID: <20020811232546.GA27168@anakin.wychk.org>
References: <20020810102441.GA1126@anakin.wychk.org> <200208112046.AAA16082@sex.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=big5
Cc: netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
Content-Disposition: inline
In-Reply-To: <200208112046.AAA16082@sex.inr.ac.ru>
List-Id: netdev.vger.kernel.org

Yo,

On Mon, Aug 12, 2002 at 12:46:51AM +0400, kuznet@ms2.inr.ac.ru wrote:
> Hello!
> 
> > connect() doesn't return -EINTR on signal,
> 
> It does, when you ask not to restart after signal.
> 

True. What I was getting at is the default behavior of an OS with 
interruptibility for connect(), i.e. using signal() instead of
specifying / unspecifying the SA_RESTART flag with sigaction(), though
I will acknowledge that if you're using signal() you may be in for 
some unpleasant surprises with signal interruptibility anyway.

I've done a bit more testing. It seems that OSF1 (Digital UNIX) will not 
return -EINTR by default with signal(), contrary to what I have previously
stated. I must have been on drugs. However, Solaris will do this 
(SunOS 5.6) by default with signal(), and I wanted to know what 
is the "correct" behavior for connect() by default with signal().



So, current standings are with connect() interruptibility by default
(i.e. with signal()) are:

FreeBSD 4.6-STABLE: -EINTR
Digital UNIX (OSF1 V4.0): To completion
SunOS 5.6: -EINTR
Linux (2.4): To completion


> 
> > The patch also addresses this.
> 
> It would be better if it did not. :-)
> 



I only patched it from what I observed with other Unices. :-)

I patched it largely due to observing what FreeBSD does with their
sockets connect() call.

Because my patched addresses 2 issues, if you are going to apply the
patch for the -EADDRNOTAVAIL issue, and you want a re-worked patch
without the connect() -EINTR issue, please let me know. But
it should be trivial to hand edit my prevoius patch posted.



	-- G.
	
