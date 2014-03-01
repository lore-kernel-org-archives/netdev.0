From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] ip_tunnel:multicast process cause panic due to skb->_skb_refdst NULL pointer
Date: Sat, 1 Mar 2014 18:33:54 +0100
Message-ID: <20140301173354.GA15198@order.stressinduktion.org>
References: <1393216519-9066-1-git-send-email-lucien.xin@gmail.com> <20140224145807.GG6598@order.stressinduktion.org> <CADvbK_d+B2sRCZ-aBDUz3808os2C2gvdJsQQO6_FNs7djQA9kQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: network dev <netdev@vger.kernel.org>
To: lucien xin <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:33615 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752005AbaCARdz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Mar 2014 12:33:55 -0500
Content-Disposition: inline
In-Reply-To: <CADvbK_d+B2sRCZ-aBDUz3808os2C2gvdJsQQO6_FNs7djQA9kQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 28, 2014 at 09:27:35AM +0800, lucien xin wrote:
> On Mon, Feb 24, 2014 at 10:58 PM, Hannes Frederic Sowa
> <hannes@stressinduktion.org> wrote:
> >
> > If the packet is locally forwarded we can test for IPCB(skb)->flags &
> > IPSKB_FORWARDED.
> >
> 
> thanks for  your reply,  hannes
> 
> IPSKB_FORWARDED is locally forwarded flag, but in ip_tunnel_rcv(), it
> check if the packet
> is a *looped back packet* (not about locally forwarded), the path is
> __ip_route_output_key()-->
> __mkroute_output()(rth->dst.output = ip_mc_output), then,
> ip_mc_output()-->dev_loopback_xmit(),
>  which happen when inet_sk(sk)->mc_loop =1, and in __mkroute_output(),
> rth->rt_is_input = 0.
>  In that path, IPCB(skb)->flags &IPSKB_FORWARDED always 0.
> 
> so I think 'IPCB(skb)->flags &IPSKB_FORWARDED' cannot meet the goal.

Ok, I see, sorry for the wrong hint, you're absolutely correct.

It seems to me that your original proposal is fine for me.

You would have to repost so it gets back into patchworks.

Thanks,

  Hannes
