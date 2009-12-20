From: Scott Feldman <scofeldm@cisco.com>
Subject: Re: [net-next PATCH 2/6] enic: Bug fix: try harder to fill Rx ring on
 skb allocation failures
Date: Sat, 19 Dec 2009 17:29:43 -0800
Message-ID: <C752BE07.1B019%scofeldm@cisco.com>
References: <20091220011500.GA12578@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-3.cisco.com ([171.71.176.72]:23544 "EHLO
	sj-iport-3.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754607AbZLTB3q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Dec 2009 20:29:46 -0500
In-Reply-To: <20091220011500.GA12578@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/19/09 5:15 PM, "Simon Horman" <horms@verge.net.au> wrote:

> On Sat, Dec 19, 2009 at 12:39:03PM -0800, Scott Feldman wrote:
>>>> +  rq_work_done = rq_work_to_do;
>>> 
>>> Is it intentional for rq_work_done = rq_work_to_do to become the
>>> return value?
>> 
>> That was intentional.  If the replacement skb allocation fails, we're
>> returning like we did a full budget's worth of work so we stay scheduled and
>> hopefully the next polling pass we'll get the allocations.  Before this fix,
>> there is a corner case which isn't covered: if hw has used all descs and
>> gens an intr and we get into polling and the replacement alloc fails, then
>> Rx is hung.  Hw is desc starved and we're not going to get any more intrs:
>> game over.
> 
> Ok, understood. Though doesn't this fix just narrow the scope for that
> failure? It seems that it could still occur in a pathological case.

Oh!  The intention was to fix it absolutely.  Please expand on the
pathological case your thinking about.  We need this 100% solved, but now
you've got me worried...  ;)

-scott

