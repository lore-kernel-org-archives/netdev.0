From: Patrick McHardy <kaber@trash.net>
Subject: Re: Possible race condition in conntracking
Date: Tue, 27 Jan 2009 14:14:44 +0100
Message-ID: <497F08C4.90705@trash.net>
References: <20090127075744.GA19875@eric.schwarzvogel.de> <497ED1E1.40304@trash.net> <20090127130604.GA19883@eric.schwarzvogel.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: Tobias Klausmann <klausman@schwarzvogel.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:37505 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753290AbZA0NOt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2009 08:14:49 -0500
In-Reply-To: <20090127130604.GA19883@eric.schwarzvogel.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tobias Klausmann wrote:
> Hi! 
> 
> (I've now subscribed to netdev@, so no more CCs to me are necessary).
> 
> On Tue, 27 Jan 2009, Patrick McHardy wrote:
>> That sounds plausible, but we only discard the new conntrack
>> entry on clashes. The packet should be fine, unless you drop
>> INVALID packets in your ruleset.
> 
> The ruleset currently does not contain any rules regarding
> INVALID. Consequently, we opted for the TRACE approach.
> 
>> Try tracing the packet using the TRACE target. That should show
>> whether it really disappears within netfilter and where.
> 
> I've removed the irrelevant fields like TTL, PREC etc and timing
> info from syslog from the trace after making sure nothing funky
> was going on there.
> 
> Apart from the ID field, I ended up with two identical traces.
> 
> So, as far as rule-matching is concerned, the two packets are
> handled identically. Whatever happens after this:
> 
> Jan 27 11:00:39 fw2 kernel: TRACE: nat:POSTROUTING:policy:3 IN=
> OUT=eth2.188 SRC=194.97.7.116 DST=194.97.3.83 LEN=66 TOS=0x00
> PREC=0x00 TTL=63 ID=46964 DF PROTO=UDP SPT=53452 DPT=53 LEN=46 
> 
> is making this very packet go away. The policy of nat/PR is
> ACCEPT.

This just means it passed through the last table/chain. The
only one following is conntrack confirmation.

Damn it :) I just noticed, we do indeed drop packets from
duplicate new connections in conntrack confirmation.

You should see the insert_failed conntrack counter show this
(/proc/net/stat/nf_conntrack).
