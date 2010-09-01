From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net/ipv4: push IP options to CB in
 ip_fragment
Date: Wed, 01 Sep 2010 14:46:58 -0700 (PDT)
Message-ID: <20100901.144658.135972233.davem@davemloft.net>
References: <1283204118.2405.32.camel@edumazet-laptop>
	<20100830232147.GB10754@stratus.com>
	<1283232031.2405.38.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bandan.das@stratus.com, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kaber@trash.net
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1283232031.2405.38.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 31 Aug 2010 07:20:31 +0200

> We could have a padding in front of struct br_input_skb_cb to make sure
> we dont overwrite IP (4|6) CB in bridge ?
> 
> Something like this untested patch :

This will not help Brandan's case.

His packets are coming straight from TUN/TAP.  They did not live in
the IP stack at all before hitting the bridge and then heading to
ip_fragment().

Therefore I'm inclined to agree with Herbert that we need to parse the
options explicitly before invoke ip_fragment().  We must call it with
an SKB in the state it expects, and that means with options parsing
already performed.
