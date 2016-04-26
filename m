From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] netem: Segment GSO packets on enqueue.
Date: Tue, 26 Apr 2016 11:49:58 -0700
Message-ID: <1461696598.5535.35.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1461692618-21333-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jamal Hadi Salim <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>,
	netem@lists.linux-foundation.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:34239 "EHLO
	mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752447AbcDZSuC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2016 14:50:02 -0400
Received: by mail-pf0-f175.google.com with SMTP id y69so10217136pfb.1
        for <netdev@vger.kernel.org>; Tue, 26 Apr 2016 11:50:01 -0700 (PDT)
In-Reply-To: <1461692618-21333-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-04-26 at 13:43 -0400, Neil Horman wrote:
> This was recently reported to me, and reproduced on the latest net kernel, when
> attempting to run netperf from a host that had a netem qdisc attached to the
> egress interface:

..

> The problem occurs because netem is not prepared to handle GSO packets (as it
> uses skb_checksum_help in its enqueue path, which cannot manipulate these
> frames).
> 
> The solution I think is to simply segment the skb in a simmilar fashion to the
> way we do in __dev_queue_xmit (via validate_xmit_skb), except here we always
> segment, instead of only when the interface needs us to do it.  This allows
> netem to properly drop/mangle/pass/etc the correct percentages of frames as per
> its qdisc configuration, and avoid failing its checksum operations
> 
> tested successfully by myself on the latest net kernel, to whcih this applies
> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> CC: Jamal Hadi Salim <jhs@mojatatu.com>
> CC: "David S. Miller" <davem@davemloft.net>
> CC: netem@lists.linux-foundation.org
> ---
>  net/sched/sch_netem.c | 34 +++++++++++++++++++++++++++++++++-
>  1 file changed, 33 insertions(+), 1 deletion(-)


This is not correct.

I want my TSO packets being still TSO after netem traversal.

Some of us use netem at 40Gbit speed ;)
