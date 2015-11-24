From: Phil Sutter <phil@nwl.cc>
Subject: Re: [iproute PATCH] iproute: fix filter_nlmsg
Date: Tue, 24 Nov 2015 13:40:16 +0100
Message-ID: <20151124124016.GC23115@orbit.nwl.cc>
References: <1446117347-9110-1-git-send-email-phil@nwl.cc>
 <20151103163359.0a38d573@xeon-e3>
 <20151104155424.GF26876@orbit.nwl.cc>
 <20151123162024.727a3d07@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:46947 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752960AbbKXMkR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Nov 2015 07:40:17 -0500
Content-Disposition: inline
In-Reply-To: <20151123162024.727a3d07@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 23, 2015 at 04:20:24PM -0800, Stephen Hemminger wrote:
> On Wed, 4 Nov 2015 16:54:24 +0100
> Phil Sutter <phil@nwl.cc> wrote:
> 
> > On Tue, Nov 03, 2015 at 04:33:59PM -0800, Stephen Hemminger wrote:
> > > On Thu, 29 Oct 2015 12:15:47 +0100
> > > Phil Sutter <phil@nwl.cc> wrote:
> > > 
> > > > This patch is based upon an old Fedora bug[1] regarding the routing
> > > > setup of PPP links. I'm not quite sure if it still applies today or how
> > > > to trigger it, but looking at the change introducing this, it's
> > > > obviously a bug.
> > > > 
> > > > [1] https://bugzilla.redhat.com/show_bug.cgi?id=622782
> > > > 
> > > > Fixes: 4479282 ("iproute2: filter routing entries based on clone flag")
> > > > Signed-off-by: Phil Sutter <phil@nwl.cc>
> > > > ---
> > > >  ip/iproute.c | 2 +-
> > > >  1 file changed, 1 insertion(+), 1 deletion(-)
> > > > 
> > > > diff --git a/ip/iproute.c b/ip/iproute.c
> > > > index eab512d..ea7e9aa 100644
> > > > --- a/ip/iproute.c
> > > > +++ b/ip/iproute.c
> > > > @@ -151,7 +151,7 @@ static int filter_nlmsg(struct nlmsghdr *n, struct rtattr **tb, int host_len)
> > > >  	if (r->rtm_family == AF_INET6 && table != RT_TABLE_MAIN)
> > > >  		ip6_multiple_tables = 1;
> > > >  
> > > > -	if (filter.cloned == !(r->rtm_flags&RTM_F_CLONED))
> > > > +	if (filter.cloned && !(r->rtm_flags&RTM_F_CLONED))
> > > >  		return 0;
> > > >  
> > > >  	if (r->rtm_family == AF_INET6 && !ip6_multiple_tables) {
> > > 
> > > Holding off on this, until there is an obvious reproduction.
> > > The patch looks right but this code has been around a long time and don't want
> > > any surprised users.
> > 
> > Looking more into this, I found commit c73f3e0 ("iproute2: dont filter
> > cached routes on iproute_get") which bases explicitly on the behaviour
> > as we have now (comparison instead of boolean AND).
> > 
> > The above change at least affects showing routes for IPv6. With it
> > applied, 'ip r s' prints the routing cache along with normal routing
> > table entries, without it one has to explicitly ask for cached entries
> > in order for them to show up ('ip r s cached'). What do you think which
> > is the correct behaviour?
> 
> I think changing the default output would confuse users.
> Better to keep the status quo. Don't know how Fedora deals with the fact
> they print different result than other distro's, but not my problem.

Actually, that patch was already dropped from Fedora23 and onwards
anyway. Also, it seems to affect IPv6 only which nobody really seems to
use. ;)

Anyways, my assumption of this being "obviously a bug" was clearly wrong
and I even couldn't find a reason how the proposed change could fix the
reported problem.

Thanks, Phil
