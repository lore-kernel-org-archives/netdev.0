From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [PATCH] bridge: make bridge-nf-call-*tables default
 configurable
Date: Tue, 30 Jun 2009 22:16:35 +0200 (CEST)
Message-ID: <alpine.LSU.2.00.0906302211300.25417@fbirervta.pbzchgretzou.qr>
References: <1246379267.3749.42.camel@blaa> <20090630170027.GA22691@gondor.apana.org.au> <20090630.120608.193727499.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: herbert@gondor.apana.org.au, markmc@redhat.com,
	netdev@vger.kernel.org, kaber@trash.net,
	netfilter-devel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sovereign.computergmbh.de ([85.214.69.204]:41120 "EHLO
	sovereign.computergmbh.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752859AbZF3UQe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jun 2009 16:16:34 -0400
In-Reply-To: <20090630.120608.193727499.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Tuesday 2009-06-30 21:06, David Miller wrote:
>Adding appropriate lists and persons to CC:
>
>> On Tue, Jun 30, 2009 at 05:27:47PM +0100, Mark McLoughlin wrote:
>>> 
>>> However, because nf_conntrack introduces an skb_orphan(), it is now
>>> recommended that bridge-nf-call-iptables be disabled completely so as
>>> to ensure features like TUNSETSNDBUF work as expected.
>> 
>> Patrick, does conntrack ever make sense for bridging? Perhaps
>> we should get rid of that completely?

It makes sense absolutely. Consider:

* packet enters bridge
* NF_HOOK(PF_INET6, NF_INET_PRE_ROUTING, ...) is called by nr_netfilter.c
* (connection tracking entry is set up)
* let bridging decision be "local delivery"
