From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] NET: Multiqueue network device support.
Date: Mon, 11 Jun 2007 14:08:45 +0200
Message-ID: <466D3B4D.7080905@trash.net>
References: <D5C1322C3E673F459512FB59E0DDC32902FC675E@orsmsx414.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	David Miller <davem@davemloft.net>, hadi@cyberus.ca,
	netdev@vger.kernel.org, jeff@garzik.org,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:40965 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750767AbXFKMLM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jun 2007 08:11:12 -0400
In-Reply-To: <D5C1322C3E673F459512FB59E0DDC32902FC675E@orsmsx414.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Waskiewicz Jr, Peter P wrote:
>>>If they have multiple TX queues, independantly programmable, that 
>>>single lock is stupid.
>>>
>>>We could use per-queue TX locks for such hardware, but we can't 
>>>support that currently.
>>
>>There could be bad packet reordering with this (like some SMP 
>>routers used to do).
> 
> 
> My original multiqueue patches I submitted actually had a per-queue Tx
> lock, but it was removed since the asymmetry in the stack for locking
> was something people didn't like.  Locking a queue for ->enqueue(),
> unlocking, then locking for ->dequeue(), unlocking, was something people
> didn't like very much.  Also knowing what queue to lock on ->enqueue()
> was where the original ->map_queue() idea came from, since we wanted to
> lock before calling ->enqueue().


I guess there were a few more reasons why people (at least me) didn't
like it. IIRC It didn't include any sch_api locking changes, to it
was completely broken wrt. concurrent configuration changes (easy
fixable though). Additionally it assumed that classification was
deterministic and two classify calls would return the same result,
which is not necessarily true and might have resulted in locking
the wrong queue, and it didn't deal with TC actions doing stuff
to a packet during the first classification.
