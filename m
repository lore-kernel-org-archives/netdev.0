From: Michal Soltys <soltys@ziu.info>
Subject: Re: Question about HFSC atm+man patches
Date: Mon, 24 Nov 2008 14:56:42 +0100
Message-ID: <492AB29A.3010601@ziu.info>
References: <49292F54.4020803@ziu.info> <4929632F.3050200@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.ppgk.com.pl ([80.53.243.36]:26975 "EHLO relay.ppgk.com.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752318AbYKXOGP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Nov 2008 09:06:15 -0500
In-Reply-To: <4929632F.3050200@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy wrote:
> Michal Soltys wrote:
>> I'm thinking about writing few simple patches that would introduce layer
>> 2 adaptation to HFSC. Generally - instead of preparing adjusted rate
>> table like some of the other qdiscs do (tbf, htb, ...), hfsc could
>> simply adjust packets' lengths in qdisc code (and there are just few 
>> places where it's done) - as it's used for all time / curve related 
>> computations later. So the whole thing should be, at least in theory, 
>> pretty straightforward.
>>
>> The tc's interface would of course remain the same - that is - linklayer
>> and overhead options, consistently with other qdiscs.
>>
>> Would such approach be valid and possibly accepted ?
> 
> We already support generic size adjustment for all qdiscs. I'm
> not sure about the userspace interface though.
> 

More about what I have in mind - in april '08 there was set of 8 patches
-
http://kerneltrap.org/mailarchive/linux-netdev/2008/4/9/1386524/thread#mid-1386524

They added atm adaptation to tbf, htb, cbq and filter's action police.
The rate table is precalculated in userspace, and depending on tc
invocation - will be either unaltered, or the times will be set
according to lengths aligned to atm cells (tc_calc_rtable, in tc/tc_core.c).

On the kernel's side, rata table is consulted through qdisc_l2t
function, where overhead and cell_align are taken into account as well.

Anyway - HFSC wasn't included in that patchset, as it didn't use rate
table - so what I have in mind is essentially:

len = hfsc_l2_adapt(q->overhead,qdisc_pkt_len(skb));

instead of

len = qdisc_pkt_len(skb);

+ setup from tc and hfsc_init (overhead parameter, pointing
hfsc_l2_adapt to required function, sanity checks, etc.).

>> Another thing I'd like to add is detailed tc-hfsc man page (and maybe
>> add/update other ones - but that's for a bit later).
> 
> That would be great.

Allright, will do.


ps.

Removed linux-net from CC.

