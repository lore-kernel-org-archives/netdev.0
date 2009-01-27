From: Tobias Klausmann <klausman@schwarzvogel.de>
Subject: Re: Possible race condition in conntracking
Date: Tue, 27 Jan 2009 14:06:04 +0100
Message-ID: <20090127130604.GA19883@eric.schwarzvogel.de>
References: <20090127075744.GA19875@eric.schwarzvogel.de> <497ED1E1.40304@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eric.schwarzvogel.de ([194.97.4.250]:42356 "EHLO
	eric.schwarzvogel.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753255AbZA0NGH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2009 08:06:07 -0500
Content-Disposition: inline
In-Reply-To: <497ED1E1.40304@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi! 

(I've now subscribed to netdev@, so no more CCs to me are necessary).

On Tue, 27 Jan 2009, Patrick McHardy wrote:
> That sounds plausible, but we only discard the new conntrack
> entry on clashes. The packet should be fine, unless you drop
> INVALID packets in your ruleset.

The ruleset currently does not contain any rules regarding
INVALID. Consequently, we opted for the TRACE approach.

> Try tracing the packet using the TRACE target. That should show
> whether it really disappears within netfilter and where.

I've removed the irrelevant fields like TTL, PREC etc and timing
info from syslog from the trace after making sure nothing funky
was going on there.

Apart from the ID field, I ended up with two identical traces.

So, as far as rule-matching is concerned, the two packets are
handled identically. Whatever happens after this:

Jan 27 11:00:39 fw2 kernel: TRACE: nat:POSTROUTING:policy:3 IN=
OUT=eth2.188 SRC=194.97.7.116 DST=194.97.3.83 LEN=66 TOS=0x00
PREC=0x00 TTL=63 ID=46964 DF PROTO=UDP SPT=53452 DPT=53 LEN=46 

is making this very packet go away. The policy of nat/PR is
ACCEPT.

Presuming this:
http://xkr47.outerspace.dyndns.org/netfilter/packet_flow/packet_flow9.png

is accurate, I'm not sure what could drop the packet. We're not
using QoS or tunneling on the packetfilter in question. This
happens on two different machines (the machines are of the same
type, but they have different NICs), so I doubt it's a hardware
or driver issue.



-- 
printk("Cool stuff's happening!\n")
        linux-2.4.3/fs/jffs/intrep.c
