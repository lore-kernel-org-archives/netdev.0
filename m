From: =?iso-8859-1?Q?Hans_Schillstr=F6m?= <hans.schillstrom@ericsson.com>
Subject: RE: [PATCH] tcp: do not create inetpeer on SYNACK message
Date: Fri, 1 Jun 2012 23:34:14 +0200
Message-ID: <C8A6796DE7C66C4ABCBC18106CB6C1CC164D13A516@ESESSCMS0356.eemea.ericsson.se>
References: <1338501397.2760.1395.camel@edumazet-glaptop>,<1338534026.2760.1451.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: netdev <netdev@vger.kernel.org>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	David Miller <davem@davemloft.net>,
	Neal Cardwell <ncardwell@google.com>,
	Tom Herbert <therbert@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw7.ericsson.se ([193.180.251.48]:53981 "EHLO
	mailgw7.ericsson.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932538Ab2FAVeR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jun 2012 17:34:17 -0400
In-Reply-To: <1338534026.2760.1451.camel@edumazet-glaptop>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric
>Another problem on SYNFLOOD/DDOS attack is the inetpeer cache getting
>larger and larger, using lots of memory and cpu time.
>
>>tcp_v4_send_synack()
>->inet_csk_route_req()
> ->ip_route_output_flow()
>  ->rt_set_nexthop()
>   ->rt_init_metrics()
>    ->inet_getpeer( create = true)
>
>This is a side effect of commit a4daad6b09230 (net: Pre-COW metrics for
>TCP) added in 2.6.39
>
>Possible solution :
>
>Instruct inet_csk_route_req() to remove FLOWI_FLAG_PRECOW_METRICS
>

It think we are on the right way now,

Some results from one of our testers:
before applying "reflect SYN queue_mapping into SYNACK"

"(The latest one from Eric is not included. I am building with
that one right now.)
Results were that with the same number of SYN/s, load went down
30% on each of the three Cpus that were handling the SYNs.
Great !!!"

I'm looking forward to see the results of the latests patch.

Then I think conntrack need a little shape up, like a "mini-conntrack"
it is way to expensive to alloc a full "coontack for every SYN.

I have a bunch of patches and ideas for that...

Thanks Eric for a great job

/Hans
 