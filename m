From: Phil Sutter <phil@nwl.cc>
Subject: Re: [iproute PATCH v2 7/7] ip/tcp_metrics: Simplify process_msg a bit
Date: Tue, 21 Jun 2016 19:07:14 +0200
Message-ID: <20160621170714.GE19797@orbyte.nwl.cc>
References: <1466525921-15738-1-git-send-email-phil@nwl.cc>
 <1466525921-15738-8-git-send-email-phil@nwl.cc>
 <20160621095343.0936eefc@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	David Ahern <dsa@cumulusnetworks.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Julien Floret <julien.floret@6wind.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:42487 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752288AbcFURHQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Jun 2016 13:07:16 -0400
Content-Disposition: inline
In-Reply-To: <20160621095343.0936eefc@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 21, 2016 at 09:53:43AM -0700, Stephen Hemminger wrote:
> On Tue, 21 Jun 2016 18:18:41 +0200
> Phil Sutter <phil@nwl.cc> wrote:
> 
> > By combining the attribute extraction and check for existence, the
> > additional indentation level in the 'else' clause can be avoided.
> > 
> > In addition to that, common actions for 'daddr' are combined since the
> > function returns if neither of the branches are taken.
> > 
> > Signed-off-by: Phil Sutter <phil@nwl.cc>
> > ---
> >  ip/tcp_metrics.c | 45 ++++++++++++++++++---------------------------
> >  1 file changed, 18 insertions(+), 27 deletions(-)
> > 
> > diff --git a/ip/tcp_metrics.c b/ip/tcp_metrics.c
> > index f82604f458ada..899830c127bcb 100644
> > --- a/ip/tcp_metrics.c
> > +++ b/ip/tcp_metrics.c
> > @@ -112,47 +112,38 @@ static int process_msg(const struct sockaddr_nl *who, struct nlmsghdr *n,
> >  	parse_rtattr(attrs, TCP_METRICS_ATTR_MAX, (void *) ghdr + GENL_HDRLEN,
> >  		     len);
> >  
> > -	a = attrs[TCP_METRICS_ATTR_ADDR_IPV4];
> > -	if (a) {
> > +	if ((a = attrs[TCP_METRICS_ATTR_ADDR_IPV4])) {
> 
> NAK, plus it fails checkpatch

Oh well, I'll drop it then and get rid of the remaining checkpatch
warnings before resending.

Thanks, Phil
