From: kuznet@ms2.inr.ac.ru
Subject: Re: [PATCH] connect() return value.
Date: Wed, 14 Aug 2002 04:36:24 +0400 (MSD)
Sender: owner-netdev@oss.sgi.com
Message-ID: <200208140036.EAA22833@sex.inr.ac.ru>
References: <20020813235103.GA28432@anakin.wychk.org>
Mime-Version: 1.0
Cc: netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: glee@gnupilgrims.org (Geoffrey Lee)
In-Reply-To: <20020813235103.GA28432@anakin.wychk.org> from "Geoffrey Lee" at Aug 14, 2 09:51:03 am
List-Id: netdev.vger.kernel.org

Hello!

> What are you intending to change? :-)

connect.

> > Could you repeat that test with read() after incomplete connect?
> > That your test was apparently invalid because of the same errno mistake,
> > so results may be different. Only, please, use read() with non-zero length.
				 ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^


> the read / write call. After that, we then we issue a 0 length
> read / write,

I asked you not to do this. This is pathological case, and return
value from this presents only academic interest.


> We find the errno after the first connect is indeed EINPROGRESS. A 
> read with 0 length returns -1, with an errno of 134. That corresponds
> to ENOTCONN on Solaris.

F.e. if Solaris behaves in this way on normal not-nil read/write,
it is fatally buggy. I do not understand why it works after this,
just by plain luck.

read/write on not-yet-connected socket can only block (when blocking)
or return EAGAIN otherwise. Well, or complete sucessfully.

Alexey
