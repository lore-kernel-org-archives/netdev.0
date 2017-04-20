From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [PATCH v4 net-next RFC] net: Generic XDP
Date: Thu, 20 Apr 2017 18:09:51 -0400
Message-ID: <20170420220951.GO4730@C02RW35GFVH8.dhcp.broadcom.net>
References: <20170418.150708.1605529107204449972.davem@davemloft.net>
 <20170418.152916.1361453741909754079.davem@davemloft.net>
 <20170419142903.GJ4730@C02RW35GFVH8.dhcp.broadcom.net>
 <20170419.214049.2190624657363276447.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: alexei.starovoitov@gmail.com, michael.chan@broadcom.com,
        netdev@vger.kernel.org, xdp-newbies@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:36341 "EHLO
        mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S944867AbdDTWKA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2017 18:10:00 -0400
Received: by mail-qt0-f193.google.com with SMTP id t52so9585561qtb.3
        for <netdev@vger.kernel.org>; Thu, 20 Apr 2017 15:09:59 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170419.214049.2190624657363276447.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 19, 2017 at 09:40:49PM -0400, David Miller wrote:
> From: Andy Gospodarek <andy@greyhouse.net>
> Date: Wed, 19 Apr 2017 10:29:03 -0400
> 
> > So I tried a variety of things and the simplest change on top of yours that
> > works well for xdp1, xdp2, and xdp_tx_iptunnel. 
> > 
> > diff --git a/net/core/dev.c b/net/core/dev.c
> > index b3d3a6e..1bab3dc 100644
> > --- a/net/core/dev.c
> > +++ b/net/core/dev.c
> > @@ -4316,11 +4316,11 @@ static u32 netif_receive_generic_xdp(struct sk_buff *skb,
> >  
> >  	off = xdp.data - orig_data;
> >  	if (off)
> > -		__skb_push(skb, off);
> > +		__skb_push(skb, -off);
> 
> We have to handle both pushing and popping headers, so could you
> please test the snippet I asked you to try?
> 

I will tomorrow or by Monday of next week.

I'm also going to hack^W write a quick test app to exercise it as well.


> > 	if (off > 0)
> > 		__skb_pull(skb, off);
> > 	else if (off < 0)
> > 		__skb_push(skb, -off);
> 
> Thanks.
