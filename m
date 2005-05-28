From: jamal <hadi@cyberus.ca>
Subject: Re: PATCH: rtnetlink explicit flags setting
Date: Fri, 27 May 2005 21:48:13 -0400
Message-ID: <1117244893.6251.41.camel@localhost.localdomain>
References: <1117197157.6688.24.camel@localhost.localdomain>
	 <20050527125010.GO15391@postel.suug.ch>
	 <1117202331.6383.39.camel@localhost.localdomain>
	 <20050527141320.GQ15391@postel.suug.ch>
	 <1117206091.6383.73.camel@localhost.localdomain>
	 <20050527151913.GA15391@postel.suug.ch>
	 <1117209466.6383.106.camel@localhost.localdomain>
	 <20050527165935.GC15391@postel.suug.ch>
	 <1117242749.6251.15.camel@localhost.localdomain>
	 <20050528012810.GN15391@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050528012810.GN15391@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 2005-28-05 at 03:28 +0200, Thomas Graf wrote:
> * jamal <1117242749.6251.15.camel@localhost.localdomain> 2005-05-27 21:12
> > > Yet unconverted
> > > are: netfilter, net/sched/ tcp_diag, xfrm, kernel/audit.
> > > 
> > 
> > I didnt find any issues with these as far as PID extrapolation.
> 
> I should have written, yet unchecked.
> 

I did check netfilter, net/sched/ tcp_diag, xfrm and they do things
right.


> > > Do not apply these patches yet, they're way too intrusive
> > 
> > Do you mean the two patches? Those looked fine to me;
> 
> Yes, those two patches. My part comes directly out of my fingers
> and is only compile tested. I didn't even run them yet.
> 

Hrm - you should probably have said that in the patch text ;-> 
I did test the one i sent - basic things and by code inspection saw
little risk as well. Perhaps we should push mine then you can add on top
of it.

> > i.e its mostly the patch i posted this morning with the new Macros, no?
> 
> I went through all users of NLMSG_PUT in the modules you touched and
> checked if they properly set NLM_F_MULTI and used the new macro when
> appropriate.
> 
> Anyways, I want to be careful with this, there might be userspace
> apps which rely on pid being filled in from siocb->scm->creds or
> userspace apps which don't expect the NLM_F_MULTI flag even when
> they should so we should check with all parties involved.
> 

I dont see any issues with my original patch or for that matter yours
except for now that you are saying you havent compiled it even ;->.
All dumps MUST set NLM_F_MULTI - thats the main change really.
All non-dump paths may set NLM_F_MULTI, and from that angle, if theres
any bugs in the old code they are maintained ;->

So how about we push my original patch instead?

cheers,
jamal
