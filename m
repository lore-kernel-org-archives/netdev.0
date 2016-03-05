From: Phil Sutter <phil@nwl.cc>
Subject: Re: [iproute PATCH] libnetlink: Double the dump buffer size
Date: Sat, 5 Mar 2016 01:57:46 +0100
Message-ID: <20160305005600.6D45B6020E@mail.nwl.cc>
References: <8e235f49b8314d70bbf76709a81c4d84@HQ1WP-EXMB11.corp.brocade.com>
 <20160304153553.47e8741d@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:35103 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757051AbcCEA4D (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Mar 2016 19:56:03 -0500
Content-Disposition: inline
In-Reply-To: <20160304153553.47e8741d@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 04, 2016 at 03:35:53PM -0800, Stephen Hemminger wrote:
> On Fri, 4 Mar 2016 18:57:28 +0000
> Phil Sutter <phil@nwl.cc> wrote:
> 
> > There have been reports about 'ip addr' printing "Message truncated" on
> > systems with large numbers of VFs. Although I haven't been able to get
> > my hands on hardware suitable to reproduce this, increasing the dump
> > buffer has been reported to resolve the issue. For want of a better
> > idea, just double the buffer size to 32k.
> > 
> > Feels like this opportunistic buffer size selection is rather
> > workarounding a design flaw in libnetlink or maybe even the netlink
> > protocol itself.
> > 
> > Signed-off-by: Phil Sutter <phil@nwl.cc>
> > ---
> >  lib/libnetlink.c | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > diff --git a/lib/libnetlink.c b/lib/libnetlink.c
> > index d6b5fd3e8a493..245c4ca216753 100644
> > --- a/lib/libnetlink.c
> > +++ b/lib/libnetlink.c
> > @@ -223,7 +223,7 @@ int rtnl_dump_filter_l(struct rtnl_handle *rth,
> >  		.msg_iov = &iov,
> >  		.msg_iovlen = 1,
> >  	};
> > -	char buf[16384];
> > +	char buf[32768];
> >  	int dump_intr = 0;
> >  
> >  	iov.iov_base = buf;
> 
> I thought this was addressed in kernel by making the VF info optional.
> The netlink protocol is showing some strain, this is one of them.

Oh, thanks for pointing this out. Testing was done with a RHEL7 kernel
only, so I can't tell whether this still applies to upstream.

What do you mean with 'optional'? Doesn't this imply that it is still
possible to request a dump which will exhaust buffer space in a single
message? Maybe just point me at the relevant kernel commit and I'll go
figure myself.

Thanks, Phil
