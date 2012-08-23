From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: Re[2]:  [PATCH 05/19] netfilter: nf_conntrack_ipv6: improve
 fragmentation handling
Date: Thu, 23 Aug 2012 16:49:20 +0200
Message-ID: <1345733360.3069.380.camel@localhost>
References: <mdaatbj.b2f3561b17fe4f00a6e947611a0959a1@obelix.schillstrom.com>
	 <alpine.LFD.2.00.1208220954260.1698@ja.ssi.bg>
	 <alpine.LFD.2.00.1208221014000.1698@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Hans Schillstrom <hans@schillstrom.com>,
	Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	Hans Schillstrom <hans.schillstrom@ericsson.com>
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.00.1208221014000.1698@ja.ssi.bg>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2012-08-22 at 10:16 +0300, Julian Anastasov wrote:
> 	Hello,
> 
> On Wed, 22 Aug 2012, Julian Anastasov wrote:
> 
> > On Wed, 22 Aug 2012, Hans Schillstrom wrote:
> > 
> > > >Perhaps we could change/fix the MTU check in IPVS?
> > > >(This would also solve issues I've seen with TSO/GSO frames, hitting
> > > >this code path).
> > > >
> > > I ran into this as well, 
> > > try this for the mtu check.
> > > 
> > >        if ((!skb->local_df && skb->len > mtu && !skb_is_gso(skb)) ||
> > >            (IP6CB(skb)->frag_max_size && IP6CB(skb)->frag_max_size > mtu)) {
> > 
> > 	Better without local_df check, it is our job to
> > set it.

Will the IPVS usage of local_df, conflict with Patrick's usage?



> 	Ops, sorry. It seems now nf_ct_frag6_reasm (Patch 02/18)
> will set head->local_df = 1, so we should check local_df
> as Hans said.

With Hans'es version of the MTU check, IPVS seems to work again (with
Patricks patches applied).

(Also spotted the GSO problem I had with IPv6 + DR, and send an upstream
fix...)

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer


