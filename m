From: David Miller <davem@davemloft.net>
Subject: Re: [IPV4] ip_gre: should take care of CONFIG_IPV6_MODULE
Date: Tue, 22 Jan 2008 02:22:46 -0800 (PST)
Message-ID: <20080122.022246.174359624.davem@davemloft.net>
References: <4795A096.60904@cosmosbay.com>
	<4795A786.5080606@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35233
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755003AbYAVKWj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2008 05:22:39 -0500
In-Reply-To: <4795A786.5080606@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Tue, 22 Jan 2008 09:21:26 +0100

> Eric Dumazet wrote:
> > If IPV6 is configured as a module, GRE code misses some IPV6 parts.
> 
> 
> I believe this is intentional to avoid a runtime dependency on ipv6.
> Fixing this without pulling in the ipv6 module would be preferrable.

Unfortunately this is true.

The only symbol it really needs that isn't provided statically
is icmpv6_send() which is very unfortunate.

Other things it wants like ipv6_addr_type() are already provided
statically in net/ipv6/addrconf_core.c and the appropriate
net/ipv6/Makefile:obj-y rules.
