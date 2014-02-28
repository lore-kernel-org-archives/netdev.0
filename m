From: lucien xin <lucien.xin@gmail.com>
Subject: Re: [PATCH] ip_tunnel:multicast process cause panic due to
 skb->_skb_refdst NULL pointer
Date: Fri, 28 Feb 2014 09:27:35 +0800
Message-ID: <CADvbK_d+B2sRCZ-aBDUz3808os2C2gvdJsQQO6_FNs7djQA9kQ@mail.gmail.com>
References: <1393216519-9066-1-git-send-email-lucien.xin@gmail.com>
	<20140224145807.GG6598@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: Xin Long <lucien.xin@gmail.com>,
	network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f46.google.com ([74.125.82.46]:43120 "EHLO
	mail-wg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751504AbaB1B1g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Feb 2014 20:27:36 -0500
Received: by mail-wg0-f46.google.com with SMTP id z12so33816wgg.5
        for <netdev@vger.kernel.org>; Thu, 27 Feb 2014 17:27:35 -0800 (PST)
In-Reply-To: <20140224145807.GG6598@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 24, 2014 at 10:58 PM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
>
> If the packet is locally forwarded we can test for IPCB(skb)->flags &
> IPSKB_FORWARDED.
>

thanks for  your reply,  hannes

IPSKB_FORWARDED is locally forwarded flag, but in ip_tunnel_rcv(), it
check if the packet
is a *looped back packet* (not about locally forwarded), the path is
__ip_route_output_key()-->
__mkroute_output()(rth->dst.output = ip_mc_output), then,
ip_mc_output()-->dev_loopback_xmit(),
 which happen when inet_sk(sk)->mc_loop =1, and in __mkroute_output(),
rth->rt_is_input = 0.
 In that path, IPCB(skb)->flags &IPSKB_FORWARDED always 0.

so I think 'IPCB(skb)->flags &IPSKB_FORWARDED' cannot meet the goal.
