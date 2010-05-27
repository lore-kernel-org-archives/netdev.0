From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH net-next-2.6] net: replace hooks in __netif_receive_skb
Date: Thu, 27 May 2010 07:47:15 -0700
Message-ID: <20100527074715.743f7420@nehalam>
References: <20100527134935.GA6916@psychotron.lab.eng.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, kaber@trash.net,
	eric.dumazet@gmail.com
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:48426 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753220Ab0E0OrV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 May 2010 10:47:21 -0400
In-Reply-To: <20100527134935.GA6916@psychotron.lab.eng.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 27 May 2010 15:49:36 +0200
Jiri Pirko <jpirko@redhat.com> wrote:

> What this patch does is it removes two receive frame hooks (for bridge and for
> macvlan) from __netif_receive_skb. These are replaced them with a general
> list of rx_handlers which is iterated thru instead.
> 
> Then a network driver (of virtual netdev like macvlan or bridge) can register
> an rx_handler for needed net device to be called from __netif_receive_skb.
> 
> Signed-off-by: Jiri Pirko <jpirko@redhat.com>

This is almost identical to my previous RFC but it is per device.

Why bother with a rx handler lock, why not just use RTNL since the
hook should only be changed from control operations.

