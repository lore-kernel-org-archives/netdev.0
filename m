From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: linux 3.13: problems with isatap tunnel device and UFO
Date: Thu, 20 Feb 2014 03:54:43 +0100
Message-ID: <20140220025443.GH1179@order.stressinduktion.org>
References: <1682505.dP4nT04FC9@h2o.as.studentenwerk.mhn.de> <1581659.JtJ1UQaXJr@h2o.as.studentenwerk.mhn.de> <20140211024403.GE11150@order.stressinduktion.org> <5911515.kv7YDRiZP1@h2o.as.studentenwerk.mhn.de> <20140217160916.GE22833@order.stressinduktion.org> <20140220024418.GG1179@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: Wolfgang Walter <linux@stwm.de>, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:39809 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752571AbaBTCyo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Feb 2014 21:54:44 -0500
Content-Disposition: inline
In-Reply-To: <20140220024418.GG1179@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 20, 2014 at 03:44:18AM +0100, Hannes Frederic Sowa wrote:
> On Mon, Feb 17, 2014 at 05:09:16PM +0100, Hannes Frederic Sowa wrote:
> > [+Cc Cong Wang]
> > 
> > Hi Cong!
> > 
> > In commit d949d826c09fb ("ipv6: Add generic UDP Tunnel segmentation") you
> > patched ip6_offload.c:
> > 
> > @@ -126,7 +128,7 @@ static struct sk_buff *ipv6_gso_segment(struct sk_buff *skb,
> >                 ipv6h = ipv6_hdr(skb);
> >                 ipv6h->payload_len = htons(skb->len - skb->mac_len -
> >                                            sizeof(*ipv6h));
> > -               if (proto == IPPROTO_UDP) {
> > +               if (!tunnel && proto == IPPROTO_UDP) {
> >                         unfrag_ip6hlen = ip6_find_1stfragopt(skb, &prevhdr);
> >                         fptr = (struct frag_hdr *)(skb_network_header(skb) +
> >                                 unfrag_ip6hlen);
> > 
> > 
> > I wonder about the !tunnel exception. This now seems to be a problem in sit
> > ufo output path, where we don't update fragmentation offsets any more thus
> > generating invalid frames.
> > 
> > I am not too firm with segmentation in case of tunnels but don't we need to
> > always update the fragmentation offset no matter what, if upper gso callback
> > produced more segments?
> 
> Not perfect nor clean (well, I don't know).
> 
> The idea is to have the segmentation at the first guessed tunnel
> header cut. I don't know how to deal with stacked tunnels yet, I guess
> we need to have a bit more state in the skb. Just to maybe keep the discussion
> going...

In-tunnel IPv6 fragmentation ids don't seem to be random at all... :/
