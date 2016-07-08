From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Fragment large datagrams even when IP_HDRINCL is
 set.
Date: Fri, 08 Jul 2016 18:41:29 -0400 (EDT)
Message-ID: <20160708.184129.1545084362199727100.davem@davemloft.net>
References: <20160608.102558.903056863834035706.davem@davemloft.net>
	<BN3PR0201MB10599C7780CBC6EB4BC2894DF9550@BN3PR0201MB1059.namprd02.prod.outlook.com>
	<alpine.LFD.2.20.1607081340430.26593@stoner.jakma.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Alan.Davey@metaswitch.com, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net
To: paul@jakma.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55246 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756241AbcGHWle (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jul 2016 18:41:34 -0400
In-Reply-To: <alpine.LFD.2.20.1607081340430.26593@stoner.jakma.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Jakma <paul@jakma.org>
Date: Fri, 8 Jul 2016 13:55:11 +0100 (BST)

> On Wed, 15 Jun 2016, Alan Davey wrote:
> 
>> The only case that would break is that where an application relies on
>> the existing (documented as a bug) feature of getting an EMSGSIZE
>> return code in the case of an over-sized packet.  Applications that
>> perform their own fragmentation would be unaffected.
> 
> If this doesn't break existing applications that are doing
> fragmentation in userspace on raw sockets (e.g. Quagga ospfd), that's
> better.
> 
> As per previous email, I'd love to be able to get rid of that code and
> have the kernel do it for me. However, I also don't want to have to do
> anything other non-trivial to that code either. :)
> 
> The issue for us is, how would we know on any given host whether the
> kernel will do the fragmentation or whether ospfd has to do it? We
> need to be able to probe for that capability, surely?

The fact is, regardless of whether you could probe for the capability
or not, you have to keep the fragmentation code around forever.

And that is yet another reason I do not want to add this change at all.

It doesn't make any existing server any simpler, in fact it makes them
all more complicated because not only do they keep the fragmentation
code, they also get new logic to test for the feature that would allow
them to avoid using it.

Sorry, there is no way I am adding this, it's a net lose.
