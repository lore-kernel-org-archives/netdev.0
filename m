From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] bridge: make bridge-nf-call-*tables default	configurable
Date: Wed, 01 Jul 2009 11:01:05 +0200
Message-ID: <4A4B25D1.6040904@trash.net>
References: <1246379267.3749.42.camel@blaa> <20090630170027.GA22691@gondor.apana.org.au> <20090630.120608.193727499.davem@davemloft.net> <alpine.LSU.2.00.0906302211300.25417@fbirervta.pbzchgretzou.qr> <20090701011528.GA28676@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jan Engelhardt <jengelh@medozas.de>,
	David Miller <davem@davemloft.net>, markmc@redhat.com,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:52481 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754861AbZGAJBJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jul 2009 05:01:09 -0400
In-Reply-To: <20090701011528.GA28676@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Tue, Jun 30, 2009 at 10:16:35PM +0200, Jan Engelhardt wrote:
>> It makes sense absolutely. Consider:
>>
>> * packet enters bridge
>> * NF_HOOK(PF_INET6, NF_INET_PRE_ROUTING, ...) is called by nr_netfilter.c
>> * (connection tracking entry is set up)
>> * let bridging decision be "local delivery"
> 
> No, my question is does it ever make sense to use conntrack as
> part of bridge netfilter.  That is, do you ever want to test it
> in your rules that are run as part of bridge netfilter.

Probably not, but thats not how its used currently. The packets are
passed to IP netfilter, which performs connection tracking. I'm not
sure how we could avoid the negative effects while still allowing this.
