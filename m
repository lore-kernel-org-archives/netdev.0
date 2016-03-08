From: Phil Sutter <phil@nwl.cc>
Subject: Re: [iproute PATCH] libnetlink: Double the dump buffer size
Date: Tue, 8 Mar 2016 14:28:32 +0100
Message-ID: <20160308132832.GA9698@orbyte.nwl.cc>
References: <8e235f49b8314d70bbf76709a81c4d84@HQ1WP-EXMB11.corp.brocade.com>
 <20160304153553.47e8741d@xeon-e3>
 <20160305005746.GS28939@base.sg13b.nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Stephen Hemminger <shemming@brocade.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:37034 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751441AbcCHN2e (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Mar 2016 08:28:34 -0500
Content-Disposition: inline
In-Reply-To: <20160305005746.GS28939@base.sg13b.nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Mar 05, 2016 at 01:57:46AM +0100, Phil Sutter wrote:
> On Fri, Mar 04, 2016 at 03:35:53PM -0800, Stephen Hemminger wrote:
> > On Fri, 4 Mar 2016 18:57:28 +0000
> > Phil Sutter <phil@nwl.cc> wrote:
> > 
> > > There have been reports about 'ip addr' printing "Message truncated" on
> > > systems with large numbers of VFs. Although I haven't been able to get
> > > my hands on hardware suitable to reproduce this, increasing the dump
> > > buffer has been reported to resolve the issue. For want of a better
> > > idea, just double the buffer size to 32k.
> > > 
> > > Feels like this opportunistic buffer size selection is rather
> > > workarounding a design flaw in libnetlink or maybe even the netlink
> > > protocol itself.
> > > 
> > > Signed-off-by: Phil Sutter <phil@nwl.cc>
> > > ---
> > >  lib/libnetlink.c | 2 +-
> > >  1 file changed, 1 insertion(+), 1 deletion(-)
> > > 
> > > diff --git a/lib/libnetlink.c b/lib/libnetlink.c
> > > index d6b5fd3e8a493..245c4ca216753 100644
> > > --- a/lib/libnetlink.c
> > > +++ b/lib/libnetlink.c
> > > @@ -223,7 +223,7 @@ int rtnl_dump_filter_l(struct rtnl_handle *rth,
> > >  		.msg_iov = &iov,
> > >  		.msg_iovlen = 1,
> > >  	};
> > > -	char buf[16384];
> > > +	char buf[32768];
> > >  	int dump_intr = 0;
> > >  
> > >  	iov.iov_base = buf;
> > 
> > I thought this was addressed in kernel by making the VF info optional.
> > The netlink protocol is showing some strain, this is one of them.
> 
> Oh, thanks for pointing this out. Testing was done with a RHEL7 kernel
> only, so I can't tell whether this still applies to upstream.
> 
> What do you mean with 'optional'? Doesn't this imply that it is still
> possible to request a dump which will exhaust buffer space in a single
> message? Maybe just point me at the relevant kernel commit and I'll go
> figure myself.

Guess I found it: c53864fd60227 ("rtnetlink: Only supply IFLA_VF_PORTS
information when RTEXT_FILTER_VF is set"). Bad news though, this patch
is already present in RHEL7 kernels. So in order to overcome this
Message Truncated problem, increasing the dump buffer size remains the
solution to go with.

Thanks, Phil
