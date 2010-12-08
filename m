From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] use total_highpages when calculating lowmem-only
 allocation sizes (dccp)
Date: Tue, 07 Dec 2010 16:49:51 -0800 (PST)
Message-ID: <20101207.164951.193734247.davem@davemloft.net>
References: <4CFD2096020000780002627B@vpn.id2.novell.com>
	<20101206.093630.104060994.davem@davemloft.net>
	<4CFE54ED02000078000266AD@vpn.id2.novell.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org
To: JBeulich@novell.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49384
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756444Ab0LHAtY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Dec 2010 19:49:24 -0500
In-Reply-To: <4CFE54ED02000078000266AD@vpn.id2.novell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Jan Beulich" <JBeulich@novell.com>
Date: Tue, 07 Dec 2010 14:38:21 +0000

>>>> On 06.12.10 at 18:36, David Miller <davem@davemloft.net> wrote:
>> From: "Jan Beulich" <JBeulich@novell.com>
>> Date: Mon, 06 Dec 2010 16:42:46 +0000
>> 
>>> For those (large) table allocations that come only from lowmem, the
>>> total amount of memory shouldn't really matter.
>>> 
>>> Signed-off-by: Jan Beulich <jbeulich@novell.com>
>> 
>> Instead of continually tweaking the bits in these code paths,
>> we should be converting them over to using a central routine
>> such as alloc_large_system_hash() where the logic is consolidated
>> _AND_ the code knows to use vmalloc() and NUMA aware allocations
>> when warranted.
> 
> Hmm, not sure. For one, alloc_large_system_hash() is (and imo
> ought to remain) an __init function. Second, looking at the one
> non-modular case (netlink_proto_init()), I don't think using this
> function would be the intention here.

I think the one and only reason DCCP and friends do not use this
interface is exactly because it's not available to modules.

So much (partially incorrect, as you found) code would be removed
if this common routine were exported and utilized.
