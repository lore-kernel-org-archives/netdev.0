From: =?gb2312?B?1cXKpL7Z?= <zhangshengju@cmss.chinamobile.com>
Subject: Re: [net-next] arp: correct return value of arp_rcv
Date: Fri, 4 Mar 2016 09:06:53 +0800
Message-ID: <000f01d175b2$24117f50$6c347df0$@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="gb2312"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: "'David Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmccmta2.chinamobile.com ([221.176.66.80]:3944 "EHLO
	cmccmta2.chinamobile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756953AbcCDBHo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2016 20:07:44 -0500
Content-Language: en-us
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
> Date: Tue,  1 Mar 2016 07:24:42 +0000
> 
> > Currently, arp_rcv() always return zero on a packet delivery upcall.
> >
> > To make its behavior more compliant with the way this API should be
> > used, this patch changes this to let it return NET_RX_SUCCESS when the
> > packet is proper handled, and NET_RX_DROP otherwise.
> >
> > Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
> 
> This change is bogus.
> 
> > @@ -880,7 +880,7 @@ out:
> >  	consume_skb(skb);
> >  out_free_dst:
> >  	dst_release(reply_dst);
> > -	return 0;
> > +	return NET_RX_SUCCESS;
> 
> Most of the paths to out: are dropping the request for one reason or
> another.
> 
> If you want to do this right you need to split these two exit paths,
convert
> consume_skb() to kfree_skb() in the drop path, and then you can return
> accurate NET_* codes.

You are right, I will change this part and sent another version later.

Shengju
