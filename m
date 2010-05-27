From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH net-next-2.6] net: replace hooks in __netif_receive_skb
 V2
Date: Thu, 27 May 2010 13:08:22 -0700
Message-ID: <20100527130822.02cb1661@nehalam>
References: <20100527180813.GA3714@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, kaber@trash.net,
	eric.dumazet@gmail.com
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:33689 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757842Ab0E0UI3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 May 2010 16:08:29 -0400
In-Reply-To: <20100527180813.GA3714@psychotron.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 27 May 2010 20:08:24 +0200
Jiri Pirko <jpirko@redhat.com> wrote:

> changelog:
> v1->v2
> 	- writers are locked by rtnl_lock (removed unnecessary spinlock)
> 	- using call_rcu in unregister
> 	- nicer macvlan_port_create cleanup
> 	- struct rx_hanler is made const in funtion parameters
> 
> What this patch does is it removes two receive frame hooks (for bridge and for
> macvlan) from __netif_receive_skb. These are replaced them with a general
> list of rx_handlers which is iterated thru instead.
> 
> Then a network driver (of virtual netdev like macvlan or bridge) can register
> an rx_handler for needed net device.
> 
> Signed-off-by: Jiri Pirko <jpirko@redhat.com>

I wonder if we really need the chaining.  What about allowing only one
hook per device (and return -EBUSY)?  That also gets rid of the allocation,
and the extra overhead.

The handler hook, has to be export GPL, since we really don't want more
network stack abuse by 3rd parties.
