From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH v3 net-next 2/2] tc: add 'needs_l2' flag to ingress qdisc
Date: Thu, 09 Apr 2015 10:20:48 -0700
Message-ID: <5526B4F0.5050300@plumgrid.com>
References: <1428535575-7736-2-git-send-email-ast@plumgrid.com>		<20150408.224404.1913719826015357860.davem@davemloft.net>		<5525EC69.1080606@plumgrid.com>	 <20150408.231456.1063648455572594170.davem@davemloft.net>	 <5525F48F.5030108@plumgrid.com> <55260C2F.608@plumgrid.com>	 <55269788.4070206@iogearbox.net> <1428593798.25985.256.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, tgraf@suug.ch,
	jiri@resnulli.us, jhs@mojatatu.com, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f170.google.com ([209.85.213.170]:37298 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753722AbbDIRUv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Apr 2015 13:20:51 -0400
Received: by igblo3 with SMTP id lo3so70553300igb.0
        for <netdev@vger.kernel.org>; Thu, 09 Apr 2015 10:20:50 -0700 (PDT)
In-Reply-To: <1428593798.25985.256.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/9/15 8:36 AM, Eric Dumazet wrote:
>
> Maybe we'll finally have a fast packet capture, instead of simply
> focusing on the filter part, which is tiny.

My plan for that was to use early_ingress_l2() hook before taps.
which will push L2 and call into the program _without_ skb_share_check.
We'll use it on the main interface where all traffic is seen.
The program will parse the packet the way it likes and redirect
the interesting packets to either different physical interface or
another tap/veth where user space will capture it. Then for 99%
of traffic on the main interface we don't pay any extra cost and if
external physical device is used for capturing then it's even cheaper.
On tracing side we were planing to use existing perf ring buffer infra
to pass some data to user space. The same helpers can be used to pass
info about the packet when user space doesn't need to see the whole
packet. In such case the bpf program will extract interesting headers
from the packet, store them into ring buffer and copy to user space
which is extremely fast.
