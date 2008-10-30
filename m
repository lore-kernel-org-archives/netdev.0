From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] udp: RCU handling for Unicast packets.
Date: Wed, 29 Oct 2008 22:40:27 -0700 (PDT)
Message-ID: <20081029.224027.163185414.davem@davemloft.net>
References: <4908C0CD.5050406@cosmosbay.com>
	<20081029201759.GF6732@linux.vnet.ibm.com>
	<4908DEDE.5030706@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paulmck@linux.vnet.ibm.com, minyard@acm.org, shemminger@vyatta.com,
	benny+usenet@amorsen.dk, netdev@vger.kernel.org,
	cl@linux-foundation.org, a.p.zijlstra@chello.nl,
	johnpol@2ka.mipt.ru, christian@myri.com
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46892
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752356AbYJ3Fkw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2008 01:40:52 -0400
In-Reply-To: <4908DEDE.5030706@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Wed, 29 Oct 2008 23:08:30 +0100

> @@ -1746,7 +1753,7 @@ void __init udp_table_init(struct udp_table *table)
>  	int i;
>  
>  	for (i = 0; i < UDP_HTABLE_SIZE; i++) {
> -		INIT_HLIST_HEAD(&table->hash[i].head);
> +		table->hash[i].head.first = (struct hlist_node *)i;

Please hide this behind some list.h interface macro, even something
as simple as INIT_HLIST_HEAD_NULLS(X, index) would suffice.

And as Corey said, the code needs more comments for something as
clever as this! :-)

Thanks.
