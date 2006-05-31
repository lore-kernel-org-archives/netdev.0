From: Patrick McHardy <kaber@trash.net>
Subject: Re: 2.6.17-rc4: netfilter LOG messages truncated via NETCONSOLE
Date: Wed, 31 May 2006 19:46:20 +0200
Message-ID: <447DD66C.30605@trash.net>
References: <20060531094626.GA23156@janus> <447DAEC9.3050003@trash.net> <20060531160611.GA25637@janus> <447DC613.10102@trash.net> <20060531172936.GB25788@janus>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	Kernel Netdev Mailing List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:56817 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S1751757AbWEaRqW
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 May 2006 13:46:22 -0400
To: Frank van Maarseveen <frankvm@frankvm.com>
In-Reply-To: <20060531172936.GB25788@janus>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Frank van Maarseveen wrote:
> On Wed, May 31, 2006 at 06:36:35PM +0200, Patrick McHardy wrote:
> 
>>The messages might get dropped when the output queue is full.
>>Does one of the drop counters shown by "ip -s link list"
>>and "tc -s -d qdisc show" increase (the other counts might also
>>give some clues)? Otherwise please apply the attached patch
>>(should fix tcpdump, last patch was incomplete) and post a dump.
> 
> 
> No visible improvement with the new patch.

Does this mean tcpdump doesn't show any packets?

> ip -s link doesn't show any
> dropped packets so far with any patch and I don't use traffic control
> that I'm aware of. But I'm not sure what to make of "tc" output, maybe
> because CONFIG_SHAPER is not set:
> 
> 	# tc -s -d qdisc show
> 	RTNETLINK answers: Invalid argument
> 	Dump terminated

Thats because you're missing CONFIG_NET_SCHED. Please enable it and
try the tc command again, without it we can't see whether the qdisc
(which is present even without CONFIG_NET_SCHED) just dropped the
packets.
