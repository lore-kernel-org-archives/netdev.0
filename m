From: Geoffrey Lee <glee@gnupilgrims.org>
Subject: Re: [PATCH] connect() return value.
Date: Wed, 14 Aug 2002 14:57:55 +1000
Sender: owner-netdev@oss.sgi.com
Message-ID: <20020814045755.GB32315@anakin.wychk.org>
References: <20020814030242.GA30872@anakin.wychk.org> <200208140416.IAA23134@sex.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=big5
Cc: netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
Content-Disposition: inline
In-Reply-To: <200208140416.IAA23134@sex.inr.ac.ru>
List-Id: netdev.vger.kernel.org

> 
> Because any error but EAGAIN/EINTR is failure. As you convinced


Yep. I thought about this as well.

If you used read with a byte count of 0 / 1, and it returned -1 to
the program with errno set to ENOTCONN, you cannot be confident whether
it is trying to complete a 3 way handshake or the connection failed.


> yourself there is no good way to detect connection completion,
> so in fact writing correct program is next to impossible.
>


I am a bit jaded about non-blocking connects on Unix, because is even
more non-portable than I ever imagined.


> Actually, never in my life I have seen a pattern of program
> with waits for EISCONN after EINTR on connect() (but lots of them
> fail when not seeing 0), so I have no idea why they work under these OSes.
> Apparently, they fail randomly.
> 


Yep.

On Solaris / Digital UNIX the 3 way handshake completes asynchronously
on EINTR. Checking for a EISCONN is one non-perfect solution to check
for a successful connection establishment.

So, in the near future, we can expect Linux to not return 0 for
non-blocking connects (i.e. the change you mentioned)?


	-- G.
