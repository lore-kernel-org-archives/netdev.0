From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next v2 3/3] bridge: send query as soon as leave is
 received
Date: Tue, 30 Apr 2013 12:05:17 +0800
Message-ID: <1367294717.3216.11.camel@cr0>
References: <1367293270-26256-1-git-send-email-amwang@redhat.com>
	 <1367293270-26256-3-git-send-email-amwang@redhat.com>
	 <20130430034538.GA20631@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>,
	Adam Baker <linux@baker-net.org.uk>
To: Herbert Xu <herbert@gondor.hengli.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:3557 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750741Ab3D3EFe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Apr 2013 00:05:34 -0400
In-Reply-To: <20130430034538.GA20631@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-04-30 at 11:45 +0800, Herbert Xu wrote:
> On Tue, Apr 30, 2013 at 11:41:10AM +0800, Cong Wang wrote:
> > From: Cong Wang <amwang@redhat.com>
> > 
> > Continue sending queries when leave is received if the user marks
> > it as a querier.
> > 
> > Cc: Herbert Xu <herbert@gondor.apana.org.au>
> > Cc: Stephen Hemminger <stephen@networkplumber.org>
> > Cc: "David S. Miller" <davem@davemloft.net>
> > Cc: Adam Baker <linux@baker-net.org.uk>
> > Signed-off-by: Cong Wang <amwang@redhat.com>
> > ---
> > v2: only send query to the port received leave
> > 
> >  net/bridge/br_multicast.c |    7 +++++++
> >  1 files changed, 7 insertions(+), 0 deletions(-)
> > 
> > diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
> > index bab3d5a..b1879c8 100644
> > --- a/net/bridge/br_multicast.c
> > +++ b/net/bridge/br_multicast.c
> > @@ -1250,6 +1250,13 @@ static void br_multicast_leave_group(struct net_bridge *br,
> >  	if (!mp)
> >  		goto out;
> >  
> > +	if (br->multicast_querier) {
> > +		if (port)
> > +			__br_multicast_enable_port(port);
> > +		else
> > +			mod_timer(&br->multicast_query_timer, jiffies);
> > +	}
> 
> AFAICS this is still sending a general query as opposed to a
> group-specific query, no?
> 

When port is NULL, the query should only be sent to bridge itself, so I
think this is what we expect, right? Since we receive leave from bridge
itself.
