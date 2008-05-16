From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: NET_SCHED cbq dropping too many packets on a bonding interface
Date: Fri, 16 May 2008 05:49:59 +0000
Message-ID: <20080516054959.GA3918@ff.dom.local>
References: <20080515091216.GA6550@ff.dom.local> <8ECDBB4EB5394859BFFACAAEE3A6EDB0@uglypunk> <482C6040.9030808@trash.net> <20080515182504.GB2936@ami.dom.local> <482C81CC.7000305@trash.net> <20080515184646.GC2936@ami.dom.local> <1A70765F4B30462EB21A3B3A8A442633@uglypunk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	Eric Dumazet <dada1@cosmosbay.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Kingsley Foreman <kingsley@internode.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.184]:19780 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751008AbYEPFqa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2008 01:46:30 -0400
Received: by nf-out-0910.google.com with SMTP id d3so297121nfc.21
        for <netdev@vger.kernel.org>; Thu, 15 May 2008 22:46:28 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1A70765F4B30462EB21A3B3A8A442633@uglypunk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 16, 2008 at 06:57:23AM +0930, Kingsley Foreman wrote:
...
> running
>
> tc qdisc add dev bond0 root pfifo limit 1000
>
> or
>
> tc qdisc add dev bond0 root handle 1: cbq bandwidth 2000Mbit avpkt 1000 
> cell 0
> tc qdisc add dev bond0 parent 1: pfifo limit 1000
>
>
> doesn't appear to be dropping packets. 
>

Great! So it looks like there is no error here unless there are needed
significantly bigger queues to stop this dropping compared to 2.6.22.
You could try to lower this limit now to something like 10 to find when
drops start to appear. Why 2.6.22 doesn't need this at all is a mistery
anyway (old scheduler?), and it would really need some work (like git
bisection) to find the reason for more than 5 or 10 packet difference.

Thanks,
Jarek P.
