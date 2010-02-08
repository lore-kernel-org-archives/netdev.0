From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH for 2.6.33] conntrack: restrict runtime hashsize modifications
Date: Mon, 08 Feb 2010 14:34:05 +0100
Message-ID: <4B7012CD.8030108@trash.net>
References: <20100203203929.GA6168@x200> <4B6AF36A.3050402@trash.net> <4B6AFE22.20304@trash.net> <20100204194744.GA4185@x200> <4B6BEC23.8020101@trash.net> <20100205220407.GA27953@x200>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jonathan@jonmasters.org,
	eric.dumazet@gmail.com, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:34505 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751744Ab0BHNeI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Feb 2010 08:34:08 -0500
In-Reply-To: <20100205220407.GA27953@x200>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alexey Dobriyan wrote:
> On Fri, Feb 05, 2010 at 11:00:03AM +0100, Patrick McHardy wrote:
>> Actually it doesn't seem like much more work to allow changing
>> table size, the main problem is that sysfs module parameters
>> don't seem to fit into the network namespace model at all.
> 
> Well, they "fit" as they're global because modules are global.
> So we can make every netns hashtable size equals to module param,
> or make it bounded by module param
> or make initial hashtable size and not bounded
> or million other things.

Feel free to suggest your preferred method.

>> Please be more specific about your suspected slowdowns.
> 
> I meant net->ct.htable_size in hash functions _if_ you're not allowing
> changing it from inside netns.
> 
>> What's "everything"? What's different about the hashsize
>> compared to the many members we already moved to per-netns
>> structs?
> 
> But whatever. I think per-netns hashtable size shouldn't be done
> that late.

This is a regression. You can not simply disable resizing and call
it a bugfix.

