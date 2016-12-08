From: =?utf-8?B?5byg6IOc5Li+?= <zhangshengju@cmss.chinamobile.com>
Subject: RE: [net-next] icmp: correct return value of icmp_rcv()
Date: Thu, 8 Dec 2016 09:09:07 +0800
Message-ID: <000001d250ef$ad1b50a0$0751f1e0$@cmss.chinamobile.com>
References: <1481093573-5123-1-git-send-email-zhangshengju@cmss.chinamobile.com> <1481120298.4930.3.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain;
        charset="utf-8"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: "'Eric Dumazet'" <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmccmta3.chinamobile.com ([221.176.66.81]:44097 "EHLO
        cmccmta3.chinamobile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752941AbcLHBJM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Dec 2016 20:09:12 -0500
In-Reply-To: <1481120298.4930.3.camel@edumazet-glaptop3.roam.corp.google.com>
Content-Language: en-us
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Eric Dumazet [mailto:eric.dumazet@gmail.com]
> Sent: Wednesday, December 07, 2016 10:18 PM
> To: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
> Cc: netdev@vger.kernel.org
> Subject: Re: [net-next] icmp: correct return value of icmp_rcv()
> 
> On Wed, 2016-12-07 at 14:52 +0800, Zhang Shengju wrote:
> > Currently, icmp_rcv() always return zero on a packet delivery upcall.
> >
> > To make its behavior more compliant with the way this API should be
> > used, this patch changes this to let it return NET_RX_SUCCESS when the
> > packet is proper handled, and NET_RX_DROP otherwise.
> >
> > Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
> > ---
> >  net/ipv4/icmp.c | 4 ++--
> >  1 file changed, 2 insertions(+), 2 deletions(-)
> >
> > diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c index 691146a..f79d7a8
> > 100644
> > --- a/net/ipv4/icmp.c
> > +++ b/net/ipv4/icmp.c
> > @@ -1047,12 +1047,12 @@ int icmp_rcv(struct sk_buff *skb)
> >
> >  	if (success)  {
> >  		consume_skb(skb);
> > -		return 0;
> > +		return NET_RX_SUCCESS;
> >  	}
> >
> >  drop:
> >  	kfree_skb(skb);
> > -	return 0;
> > +	return NET_RX_DROP;
> >  csum_error:
> >  	__ICMP_INC_STATS(net, ICMP_MIB_CSUMERRORS);
> >  error:
> 
> 
> I am curious, what external/visible effects do you expect from such a change ?
> 
> We now have a very precise monitoring of where packets are dropped
> (consume_skb()/kfree_skb())
> 
> 

I know that the return value is always ignored, I just to want to make it 
compliant with the way this API required like I said in the comment.

Thanks,
