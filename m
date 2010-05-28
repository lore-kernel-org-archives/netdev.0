From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [PATCH net-next-2.6] net: replace hooks in __netif_receive_skb V2
Date: Fri, 28 May 2010 07:51:55 +0200
Message-ID: <20100528055154.GB2823@psychotron.redhat.com>
References: <20100527180813.GA3714@psychotron.redhat.com>
 <20100527130822.02cb1661@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, kaber@trash.net,
	eric.dumazet@gmail.com
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53993 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754267Ab0E1FwC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 May 2010 01:52:02 -0400
Content-Disposition: inline
In-Reply-To: <20100527130822.02cb1661@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, May 27, 2010 at 10:08:22PM CEST, shemminger@vyatta.com wrote:
>On Thu, 27 May 2010 20:08:24 +0200
>Jiri Pirko <jpirko@redhat.com> wrote:
>
>> changelog:
>> v1->v2
>> 	- writers are locked by rtnl_lock (removed unnecessary spinlock)
>> 	- using call_rcu in unregister
>> 	- nicer macvlan_port_create cleanup
>> 	- struct rx_hanler is made const in funtion parameters
>> 
>> What this patch does is it removes two receive frame hooks (for bridge and for
>> macvlan) from __netif_receive_skb. These are replaced them with a general
>> list of rx_handlers which is iterated thru instead.
>> 
>> Then a network driver (of virtual netdev like macvlan or bridge) can register
>> an rx_handler for needed net device.
>> 
>> Signed-off-by: Jiri Pirko <jpirko@redhat.com>
>
>I wonder if we really need the chaining.  What about allowing only one
>hook per device (and return -EBUSY)?  That also gets rid of the allocation,
>and the extra overhead.

Hmm, that's a good question. I thought about it already. But I'm also wondering
if there is a possible scenario, when the chaining can be necessary. Also I do
not see any -significant- downside of having multiple handlers in a list, so I
would probably go this way now. Opinions?

>
>The handler hook, has to be export GPL, since we really don't want more
>network stack abuse by 3rd parties.

Noted, will be in the next patch version.

Jirka
