From: Jun Zhao <mypopydev@gmail.com>
Subject: Re: [PATCH v2 1/1] ipv6 : ip6mr.c : Fix can't match the IPv6
 multicast packets with input net device in netfilter FORWARD chain.
Date: Fri, 03 Aug 2012 15:10:58 +0800
Message-ID: <1343977858.4579.11.camel@barry.localdomain>
References: <1343975271-4263-1-git-send-email-mypopydev@gmail.com>
	 <20120802.234311.2108069975669469931.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:62423 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752407Ab2HCHLD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Aug 2012 03:11:03 -0400
Received: by obbuo13 with SMTP id uo13so678577obb.19
        for <netdev@vger.kernel.org>; Fri, 03 Aug 2012 00:11:03 -0700 (PDT)
In-Reply-To: <20120802.234311.2108069975669469931.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-08-02 at 23:43 -0700, David Miller wrote:
> From: Jun Zhao <mypopydev@gmail.com>
> Date: Fri,  3 Aug 2012 14:27:51 +0800
> 
> > @@ -1960,7 +1962,7 @@ static int ip6mr_forward2(struct net *net, struct mr6_table *mrt,
> >  
> >  	IP6CB(skb)->flags |= IP6SKB_FORWARDED;
> >  
> > -	return NF_HOOK(NFPROTO_IPV6, NF_INET_FORWARD, skb, skb->dev, dev,
> > +	return NF_HOOK(NFPROTO_IPV6, NF_INET_FORWARD, skb, indev, dev,
> >  		       ip6mr_forward2_finish);
> >  
> 
> This patch has the same problem I mentioned, it means someone who is
> now matching on the VIF device will now fail to do son.
> 
> You have to understand that you simply cannot change the behavior
> here without breaking something for someone.

Hi, David:

Can you give me some more details what I break in this fix?

As my understanding, in the ip6mr_forward2(), vifi is the VIF index for
output, we can get the output device used vif->dev and record input
device before change skb->dev; then used FORWARD chain match the rules. 

Tks.
