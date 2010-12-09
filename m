From: Tobias Klauser <tklauser@distanz.ch>
Subject: Re: [PATCH] bridge: Fix return value of br_multicast_add_group()
Date: Thu, 9 Dec 2010 19:53:20 +0100
Message-ID: <20101209185320.GH10190@distanz.ch>
References: <1291903356-30618-1-git-send-email-tklauser@distanz.ch> <20101209082924.6d797871@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	bridge@lists.linux-foundation.org, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from symlink.to.noone.org ([85.10.207.172]:36241 "EHLO sym.noone.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755972Ab0LITC3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Dec 2010 14:02:29 -0500
Content-Disposition: inline
In-Reply-To: <20101209082924.6d797871@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2010-12-09 at 17:29:24 +0100, Stephen Hemminger <shemminger@linux-foundation.org> wrote:
> On Thu,  9 Dec 2010 15:02:36 +0100
> Tobias Klauser <tklauser@distanz.ch> wrote:
> 
> > If br_multicast_new_group returns NULL, we would return 0 (no error) to
> > the caller, which is not what we want. Instead we should return -ENOMEM
> > in this case.
> > 
> > Also replace IS_ERR(x) || !x by IS_ERR_OR_NULL(x)
> > 
> > Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
> > ---
> >  net/bridge/br_multicast.c |    5 ++++-
> >  1 files changed, 4 insertions(+), 1 deletions(-)
> > 
> > diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
> > index 326e599..d4e1e81 100644
> > --- a/net/bridge/br_multicast.c
> > +++ b/net/bridge/br_multicast.c
> > @@ -713,8 +713,11 @@ static int br_multicast_add_group(struct net_bridge *br,
> >  
> >  	mp = br_multicast_new_group(br, port, group);
> >  	err = PTR_ERR(mp);
> > -	if (unlikely(IS_ERR(mp) || !mp))
> > +	if (IS_ERR_OR_NULL(mp)) {
> > +		if (!mp)
> > +			err = -ENOMEM;
> >  		goto err;
> > +	}
> >  
> >  	if (!port) {
> >  		hlist_add_head(&mp->mglist, &br->mglist);
> 
> I would rather fix br_multicast_new_group so it never returns
> NULL. Instead return PTR_ERR(-ENOMEM) on out of memory.

Ok, I'll change that and send an updated patch.

Thanks a lot
Tobias
