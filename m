From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [Patch net] unix: correct sk_rmem_alloc accounting
Date: Wed, 23 Jan 2013 15:55:24 +0100
Message-ID: <20130123145524.GE7005@order.stressinduktion.org>
References: <1358952191-3374-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, Yannick Koehler <yannick@koehler.name>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:46555 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751094Ab3AWOzZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2013 09:55:25 -0500
Content-Disposition: inline
In-Reply-To: <1358952191-3374-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 23, 2013 at 10:43:11PM +0800, Cong Wang wrote:
> From: Cong Wang <xiyou.wangcong@gmail.com>
> 
> Yannick reported [1] we probably forgot to account ->sk_rmem_alloc
> before moving the skb to other->sk_receive_queue. I believe
> he is right. So, just call skb_set_owner_r() before every time
> we queuing skb into other->sk_receive_queue. 

I think Eric's comment on a possible DOS is correct. Having a quick look, it
seems unix_recvq_full needs to check ->sk_rmem_alloc at a minimum.
