From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] htb: improved accuracy at high rates
Date: Sat, 20 Oct 2012 09:47:22 +0200
Message-ID: <1350719242.13333.339.camel@edumazet-glaptop>
References: <1350685582-65334-1-git-send-email-j.vimal@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Jamal Hadi Salim <jhs@mojatatu.com>,
	netdev@vger.kernel.org
To: Vimalkumar <j.vimal@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f174.google.com ([209.85.215.174]:53046 "EHLO
	mail-ea0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752532Ab2JTHr1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Oct 2012 03:47:27 -0400
Received: by mail-ea0-f174.google.com with SMTP id c13so342408eaa.19
        for <netdev@vger.kernel.org>; Sat, 20 Oct 2012 00:47:26 -0700 (PDT)
In-Reply-To: <1350685582-65334-1-git-send-email-j.vimal@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-10-19 at 15:26 -0700, Vimalkumar wrote:
> Current HTB (and TBF) uses rate table computed by
> the "tc" userspace program, which has the following
> issue:
> 
> The rate table has 256 entries to map packet lengths
> to token (time units).  With TSO sized packets, the
> 256 entry granularity leads to loss/gain of rate,
> making the token bucket inaccurate.
> 
> Thus, instead of relying on rate table, this patch
> explicitly computes the time and accounts for packet
> transmission times with nanosec granularity.
> 
> This greatly improves accuracy of HTB with a wide
> range of packet sizes.
> 
> Example:
> 
> tc qdisc add dev $dev root handle 1: \
> 	htb default 1
> 
> tc class add dev $dev classid 1:1 parent 1: \
> 	rate 1Gbit mtu 64k
> 
> Ideally it should work with all intermediate sized
> packets as well, but...
> 
> Test:
> for i in {1..20}; do
> 	(netperf -H $host -t UDP_STREAM -l 30 -- -m $size &);
> done
> 
> With size=400 bytes: achieved rate ~600Mb/s
> With size=1000 bytes: achieved rate ~835Mb/s
> With size=8000 bytes: achieved rate ~1012Mb/s
> 
> With new HTB, in all cases, we achieve ~1000Mb/s.
> Many thanks to Eric Dumazet for review and feedback.
> 
> Signed-off-by: Vimalkumar <j.vimal@gmail.com>
> ---

Thanks Vimal for this promising work.

I am going to test it, but my preliminary remarks are :


1)  This is a net-next work, so its better to add the net-next tag in
the title, as in : 

"[PATCH net-next] htb: improved accuracy at high rates"

So next submission will also include a version tag as in :

"[PATCH net-next V2] htb: improved accuracy at high rates"


2) I dont know how you generated your diff, but its not applicable
   without knowing where file is located.

So instead of

diff --git a/sch_htb.c b/sch_htb.c
index 29b942c..a808ba1 100644
--- a/sch_htb.c
+++ b/sch_htb.c

we need the proper :

diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 9d75b77..13e02b3 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c

3) Always use an up2date net-next tree before submitting an official
patch.

Here is what I have applying your patch (once I fixed the path)

patching file net/sched/sch_htb.c
Hunk #9 succeeded at 612 (offset -3 lines).
Hunk #10 succeeded at 654 (offset -3 lines).
Hunk #11 succeeded at 704 (offset -3 lines).
Hunk #12 succeeded at 715 (offset -3 lines).
Hunk #13 succeeded at 902 (offset -2 lines).
Hunk #14 succeeded at 915 (offset -2 lines).
Hunk #15 succeeded at 934 (offset -2 lines).
Hunk #16 succeeded at 1121 (offset -1 lines).

It means you worked on an old version, so its always suspicious
