From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PKT_SCHED]: Allow using nfmark as key in U32 classifier.
Date: Tue, 28 Dec 2004 14:40:22 +0100
Message-ID: <20041228134022.GA32419@postel.suug.ch>
References: <200412270715.iBR7Fffe026855@hera.kernel.org> <20041227121658.GI7884@postel.suug.ch> <1104240053.1100.53.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1104240053.1100.53.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* jamal <1104240053.1100.53.camel@jzny.localdomain> 2004-12-28 08:20
> On Mon, 2004-12-27 at 07:16, Thomas Graf wrote:
> > > ChangeSet 1.2055.37.1, 2004/11/17 16:08:01-08:00, util@deuroconsult.ro
> > > 
> > > 	[PKT_SCHED]: Allow using nfmark as key in U32 classifier.
> > > 	
> > > 	Signed-off-by: Catalin(ux aka Dino) BOIE <catab at umbrella.ro>
> > > 	Signed-off-by: David S. Miller <davem@davemloft.net>
> > 
> > I must have missed this one. This should have been implemented in the
> > metadata action module to make it available to all classifiers.
> 
> You mean meta match. 

Yes, I was thinking about implementing it as action, any objections?

> >  We
> > should really stop to add more stuff to specific classifiers which have
> > to be removed once we have metamatch. I've made a proposal on paper
> > just need some more time to cook up a patch.
> 
> I have cycles now. Are you working on this or should i invest some of my
> cycles in it? Lets fix this once and for all.

I don't care, I'm still testing the patchset to make classifer changes
consistent again. A few big changes to tcindex/route classifier need
extensive testing.

My thoughts on meta match:
  
  A match consists of a header, lvalue, rvalue and stats. The header
  contains the handle, the requested operand (eq,lt,gt) and a flag to
  invert the meaning of the match. A value consists of a type and data
  where type specifies the actual metadata to be used. A few upper bits
  of the type specify the kind, i.e. wether it's numeric or a
  bytestring. Only values with matching upper bits can be compared.
  Additionally a mask and shift operator can be configured. Why so
  complicated? Comparing two kernel meta values can useful, realdev
  == indev when classyfing on tunnels, comparing backlogs, etc. Device
  matches should be made available as both numeric and bytestring match
  to have a fastpath when ifindex is stable and a slower path which is
  more flexible to changes.
