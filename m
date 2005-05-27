From: Thomas Graf <tgraf@suug.ch>
Subject: Re: PATCH: rtnetlink explicit flags setting
Date: Fri, 27 May 2005 18:59:35 +0200
Message-ID: <20050527165935.GC15391@postel.suug.ch>
References: <1117197157.6688.24.camel@localhost.localdomain> <20050527125010.GO15391@postel.suug.ch> <1117202331.6383.39.camel@localhost.localdomain> <20050527141320.GQ15391@postel.suug.ch> <1117206091.6383.73.camel@localhost.localdomain> <20050527151913.GA15391@postel.suug.ch> <1117209466.6383.106.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1117209466.6383.106.camel@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* jamal <1117209466.6383.106.camel@localhost.localdomain> 2005-05-27 11:57
> On Fri, 2005-27-05 at 17:19 +0200, Thomas Graf wrote:
> 
> > Sure, I can come up with a patchset today which will include:
> >  o the new NLMSG_NEW macro
> >  o your patch adopted to use the new NLMSG_NEW macro
> >  o small patch to rename NLMSG_PUT_ANSWER usages into NLMSG_NEW_ANSWER
> >  o a small fallout from the new neighbour table code which gcc didn't
> >    warn me about when it should.
> > 
> > OK?
> 
> Sounds reasonable.

I took your patch, converted it to use NLMSG_NEW and finished
converting all the modules that you started. Yet unconverted
are: netfilter, net/sched/ tcp_diag, xfrm, kernel/audit.

I also fixed some uses of NL_CREDS() to fetch the pid for
message generation which is wrong. Various dumping procedures
did not set the multi flag at all, I fixed all of them.

Do not apply these patches yet, they're way too intrusive
