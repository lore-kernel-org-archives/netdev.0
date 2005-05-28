From: Thomas Graf <tgraf@suug.ch>
Subject: Re: PATCH: rtnetlink explicit flags setting
Date: Sat, 28 May 2005 03:28:10 +0200
Message-ID: <20050528012810.GN15391@postel.suug.ch>
References: <1117197157.6688.24.camel@localhost.localdomain> <20050527125010.GO15391@postel.suug.ch> <1117202331.6383.39.camel@localhost.localdomain> <20050527141320.GQ15391@postel.suug.ch> <1117206091.6383.73.camel@localhost.localdomain> <20050527151913.GA15391@postel.suug.ch> <1117209466.6383.106.camel@localhost.localdomain> <20050527165935.GC15391@postel.suug.ch> <1117242749.6251.15.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1117242749.6251.15.camel@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* jamal <1117242749.6251.15.camel@localhost.localdomain> 2005-05-27 21:12
> > Yet unconverted
> > are: netfilter, net/sched/ tcp_diag, xfrm, kernel/audit.
> > 
> 
> I didnt find any issues with these as far as PID extrapolation.

I should have written, yet unchecked.

> > I also fixed some uses of NL_CREDS() to fetch the pid for
> > message generation which is wrong. Various dumping procedures
> > did not set the multi flag at all, I fixed all of them.
> > 
> > Do not apply these patches yet, they're way too intrusive
> 
> Do you mean the two patches? Those looked fine to me;

Yes, those two patches. My part comes directly out of my fingers
and is only compile tested. I didn't even run them yet.

> i.e its mostly the patch i posted this morning with the new Macros, no?

I went through all users of NLMSG_PUT in the modules you touched and
checked if they properly set NLM_F_MULTI and used the new macro when
appropriate.

Anyways, I want to be careful with this, there might be userspace
apps which rely on pid being filled in from siocb->scm->creds or
userspace apps which don't expect the NLM_F_MULTI flag even when
they should so we should check with all parties involved.
