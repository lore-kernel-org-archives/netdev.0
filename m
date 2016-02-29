From: =?gb2312?B?1cXKpL7Z?= <zhangshengju@cmss.chinamobile.com>
Subject: Re: [net] net: fix double free issue of skbuff
Date: Mon, 29 Feb 2016 22:10:47 +0800
Message-ID: <001b01d172fa$fe14c6e0$fa3e54a0$@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="gb2312"
Content-Transfer-Encoding: 7bit
To: "'Sergei Shtylyov'" <sergei.shtylyov@cogentembedded.com>,
	<davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmccmta1.chinamobile.com ([221.176.66.79]:5354 "EHLO
	cmccmta1.chinamobile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750871AbcB2OK7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Feb 2016 09:10:59 -0500
Content-Language: en-us
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Hello.
> 
> On 2/29/2016 3:22 PM, Zhang Shengju wrote:
> 
> > If skb_reorder_vlan_header() failed, skb is freed and NULL is returned.
> > Then at skb_vlan_untag(), it will free skbuff again which cause double
> > free.
> >
> > This patch removes kfree_skb() call in function
> skb_reorder_vlan_header().
> >
> > Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
> > ---
> >   net/core/skbuff.c | 1 -
> >   1 file changed, 1 deletion(-)
> >
> > diff --git a/net/core/skbuff.c b/net/core/skbuff.c index
> > 488566b..1312d4b 100644
> > --- a/net/core/skbuff.c
> > +++ b/net/core/skbuff.c
> > @@ -4350,7 +4350,6 @@
> EXPORT_SYMBOL_GPL(skb_gso_transport_seglen);
> >   static struct sk_buff *skb_reorder_vlan_header(struct sk_buff *skb)
> >   {
> >   	if (skb_cow(skb, skb_headroom(skb)) < 0) {
> > -		kfree_skb(skb);
> >   		return NULL;
> >   	}
> 
>     You now need to remove {}.
> 
> MBR, Sergei

Thanks Sergei, I will add this in v2. 

BRs,
Shengju
