From: "Jan Beulich" <JBeulich@novell.com>
Subject: Re: [PATCH] use total_highpages when calculating lowmem-only
	 allocation sizes (dccp)
Date: Tue, 07 Dec 2010 14:38:21 +0000
Message-ID: <4CFE54ED02000078000266AD@vpn.id2.novell.com>
References: <4CFD2096020000780002627B@vpn.id2.novell.com>
 <20101206.093630.104060994.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: <akpm@linux-foundation.org>, <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <20101206.093630.104060994.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>> On 06.12.10 at 18:36, David Miller <davem@davemloft.net> wrote:
> From: "Jan Beulich" <JBeulich@novell.com>
> Date: Mon, 06 Dec 2010 16:42:46 +0000
> 
>> For those (large) table allocations that come only from lowmem, the
>> total amount of memory shouldn't really matter.
>> 
>> Signed-off-by: Jan Beulich <jbeulich@novell.com>
> 
> Instead of continually tweaking the bits in these code paths,
> we should be converting them over to using a central routine
> such as alloc_large_system_hash() where the logic is consolidated
> _AND_ the code knows to use vmalloc() and NUMA aware allocations
> when warranted.

Hmm, not sure. For one, alloc_large_system_hash() is (and imo
ought to remain) an __init function. Second, looking at the one
non-modular case (netlink_proto_init()), I don't think using this
function would be the intention here.

Jan

