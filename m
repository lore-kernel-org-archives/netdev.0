From: Geoffrey Lee <glee@gnupilgrims.org>
Subject: Re: [PATCH] connect() return value.
Date: Tue, 13 Aug 2002 15:37:04 +1000
Sender: owner-netdev@oss.sgi.com
Message-ID: <20020813053704.GA14788@anakin.wychk.org>
References: <20020813022115.GA11627@anakin.wychk.org> <200208130444.IAA20082@sex.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=big5
Cc: netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
Content-Disposition: inline
In-Reply-To: <200208130444.IAA20082@sex.inr.ac.ru>
List-Id: netdev.vger.kernel.org

On Tue, Aug 13, 2002 at 08:44:21AM +0400, kuznet@ms2.inr.ac.ru wrote:
> Hello!
> 
> > it returns -EISCONN. This behavior is consistent in all operating
> > systems which I have tested, which include the following:
> 
> This is very strange. Linux should return success once.
> 
> Probably, I should explain why I ask this. This is a necessary
> element of implementation of restartable connect(). If connect()
> is restarted after signal, it should return success on connected
> socket sometimes rather than -EISCONN.
> 



I see.

Possibly, I should be a bit clearer, to make sure that I am not
not confusing with what are you are asking for.

The summaries so far, for Linux:


(1) no signals (so it runs the sighandler but doesn't return from the
sys call until it completes), non-blocking socket:


-EINPROGRESS, -EALREADY, -EISCONN, in that order. Never returns 0.


(2) SIGALRM, set for 1 second, (and reschedules another for 1 second),
non-blocking


-EINPROGRESS, -EALREADY, -EISCONN, in that order. We note that in 
-EALREADY a signal is processed. That is the SIGALRM handler.


(3) SIGALRM, blocking:

will run sighandler but connect() returns 0 once, running connect()
again gives EISCONN.



Is that what you expected?


> 
> > On Linux (v 2.4.18):
> > 
> > read() returns 0 with an errno of 115. On Linux 115 corresponds to 
> > -EINPROGRESS.
> 
> I am sorry, this machine is not running Linux.
> 
> Zero length read() always returns zero, not depending of socket state.
> 
> 



It doesn't seem to be standardized what one should return.

So read()  / write()  is not a portable way to test if a socket has been
connected with non-blocking connect.



	-- G.
	
