From: Julia Lawall <julia@diku.dk>
Subject: Re: [PATCH 1/2] net/wireless/nl80211.c: Avoid call to genlmsg_cancel
Date: Fri, 28 Jan 2011 15:16:53 +0100 (CET)
Message-ID: <Pine.LNX.4.64.1101281515410.8546@pc-004.diku.dk>
References: <1296224232-8115-1-git-send-email-julia@diku.dk>
 <1296223267.5118.7.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: kernel-janitors@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1296223267.5118.7.camel@jlt3.sipsolutions.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 28 Jan 2011, Johannes Berg wrote:

> On Fri, 2011-01-28 at 15:17 +0100, Julia Lawall wrote:
> 
> > diff --git a/net/wireless/nl80211.c b/net/wireless/nl80211.c
> > index 9b62710..864ddfb 100644
> > --- a/net/wireless/nl80211.c
> > +++ b/net/wireless/nl80211.c
> > @@ -2718,7 +2718,7 @@ static int nl80211_get_mesh_config(struct sk_buff *skb,
> >  	hdr = nl80211hdr_put(msg, info->snd_pid, info->snd_seq, 0,
> >  			     NL80211_CMD_GET_MESH_CONFIG);
> >  	if (!hdr)
> > -		goto nla_put_failure;
> > +		goto out;
> 
> 
> > @@ -2954,7 +2955,7 @@ static int nl80211_get_reg(struct sk_buff *skb, struct genl_info *info)
> >  	hdr = nl80211hdr_put(msg, info->snd_pid, info->snd_seq, 0,
> >  			     NL80211_CMD_GET_REG);
> >  	if (!hdr)
> > -		goto nla_put_failure;
> > +		goto put_failure;
> >  
> >  	NLA_PUT_STRING(msg, NL80211_ATTR_REG_ALPHA2,
> >  		cfg80211_regdomain->alpha2);
> 
> Seems fine. Actually, since the message is freed anyhow, the call to
> genlmsg_cancel is *completely* unnecessary, I just put it in to make it
> nest better and not rely on it not having side effects.
> 
> But why did you call the label differently? :)

Because out is already used in this case, and I didn't want to change all 
of the other occurrences of nla_put_failure.  It's a bit sloppy though, 
because this code is the actual nla_put_failure.  I can change it if you 
prefer.

julia
