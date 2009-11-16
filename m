From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: PATCH net-next-2.6] linkwatch: linkwatch_forget_dev() to
 speedup device dismantle
Date: Mon, 16 Nov 2009 14:39:17 -0800
Message-ID: <20091116143917.14e4fa4f@s6510>
References: <4B019381.2010509@gmail.com>
	<4B01C938.8000705@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:47731 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754176AbZKPWjd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Nov 2009 17:39:33 -0500
In-Reply-To: <4B01C938.8000705@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 16 Nov 2009 22:50:48 +0100
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> vlan_dev_stop() ->
> 	netif_carrier_off(dev) ->
> 		linkwatch_fire_event(dev) ->
> 			dev_hold() ...
> 
> And __linkwatch_run_queue() runs up to one second later...
> 
> A generic fix to this problem is to add a linkwatch_forget_dev() method
> to unlink the device from the list of watched devices.
> 
> dev->link_watch_next becomes dev->link_watch_list (and use a bit more memory),
> to be able to unlink device in O(1).
> 
> After patch :
> time ip link del eth3.103 ; time ip link del eth3.104 ; time ip link del eth3.105
> 
> real    0m0.024s
> user    0m0.000s
> sys     0m0.000s
> 
> real    0m0.032s
> user    0m0.000s
> sys     0m0.001s
> 
> real    0m0.033s
> user    0m0.000s
> sys     0m0.000s
> 
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Acked-by: Stephen Hemminger <shemminger@vyatta.com>
