From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH v2 nf-next 3/6] netfilter: bridge: use skb->cb to track
 otherhost mangling
Date: Thu, 12 Mar 2015 19:31:13 +0100
Message-ID: <20150312183113.GA12169@breakpoint.cc>
References: <1426179925-18220-1-git-send-email-fw@strlen.de>
 <1426179925-18220-4-git-send-email-fw@strlen.de>
 <5501D498.4050003@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, Eyal Birger <eyal.birger@gmail.com>
To: Oliver Hartkopp <socketcan@hartkopp.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <5501D498.4050003@hartkopp.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Oliver Hartkopp <socketcan@hartkopp.net> wrote:
> On 03/12/2015 06:05 PM, Florian Westphal wrote:
> > nf_bridge_info->mask is used for several things, for example to remember
> > if skb->pkt_type was set to OTHER_HOST.
> > 
> > For a bridge, OTHER_HOST is expected case. For ip forward its a
> > non-starter though -- routing expects PACKET_HOST.
> > 
> > Bridge netfilter thus changes OTHER_HOST to PACKET_HOST
> > before hook invocation and then un-does it after hook traversal.
> > 
> > For this, cb[] can be used since the skb will never be used outside
> > (fake inet) bridge forwarding while in 'fake PACKET_HOST' state.
> > 
> > Signed-off-by: Florian Westphal <fw@strlen.de>
> > ---
> >  include/linux/netfilter_bridge.h |  1 -
> >  net/bridge/br_netfilter.c        | 71 ++++++++++++++++++++++++++--------------
> 
> 
> > @@ -1104,6 +1125,8 @@ static int __init br_netfilter_init(void)
> >  {
> >  	int ret;
> >  
> > +	BUILD_BUG_ON(sizeof(struct nf_bridge_skb_cb) > FIELD_SIZEOF(struct sk_buff, cb));
> > +
> 
> Please use sock_skb_cb_check_size(size) for cb size checking which is the
> 'new' check for cb sizes for netdev.

I can do this for conistency, but its technically not needed here.
