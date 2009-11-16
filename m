From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC] dev->refcnt long term holder
Date: Mon, 16 Nov 2009 11:02:07 -0800
Message-ID: <20091116110207.08b60c81@nehalam>
References: <4B019381.2010509@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:37519 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753794AbZKPTC0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Nov 2009 14:02:26 -0500
In-Reply-To: <4B019381.2010509@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 16 Nov 2009 19:01:37 +0100
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> time ip link del eth3.103 ; time ip link del eth3.104 ; time ip link del eth3.105
> 
> real	0m0.266s
> user	0m0.000s
> sys	0m0.001s
> 
> real	0m0.770s
> user	0m0.000s
> sys	0m0.000s
> 
> real	0m1.022s
> user	0m0.000s
> sys	0m0.000s
> 
> 
> One problem of current schem in vlan dismantle phase is the
> holding of device done by following chain :
> 
> vlan_dev_stop() ->
> 	netif_carrier_off(dev) ->
> 		linkwatch_fire_event(dev) ->
> 			dev_hold() ...
> 
> And __linkwatch_run_queue() run up to one second later...
> 
> Is following patch one way to avoid the problem, or should
> we add a new linkwatch_forgetpro_device(dev) method to immediately
> release the device reference (and unlink device from the list) ?
> (This would probably need a doubly linked list instead of single link list)

Or both..

-- 
