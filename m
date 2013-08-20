From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 2/2] net: netem: always adjust now/delay when not reordering
Date: Tue, 20 Aug 2013 22:31:56 +0400
Message-ID: <5213B61C.1060004@cogentembedded.com>
References: <1377011469-26151-1-git-send-email-mailings@hupie.com> <1377011469-26151-2-git-send-email-mailings@hupie.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ferry Huberts <mailings@hupie.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f180.google.com ([209.85.217.180]:50552 "EHLO
	mail-lb0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751184Ab3HTSbv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Aug 2013 14:31:51 -0400
Received: by mail-lb0-f180.google.com with SMTP id a16so736360lbj.25
        for <netdev@vger.kernel.org>; Tue, 20 Aug 2013 11:31:50 -0700 (PDT)
In-Reply-To: <1377011469-26151-2-git-send-email-mailings@hupie.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 08/20/2013 07:11 PM, Ferry Huberts wrote:

> From: Ferry Huberts <ferry.huberts@pelagic.nl>

> Not doing this (current behaviour) introduces reordering.

> The packet_len_2_sched_time call is the only thing that logically
> depends on q->rate, so move the now/delay adjustment out of the if.

> Signed-off-by: Ferry Huberts <ferry.huberts@pelagic.nl>
> ---
>   net/sched/sch_netem.c | 34 +++++++++++++++++-----------------
>   1 file changed, 17 insertions(+), 17 deletions(-)

> diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
> index abe5fa6..86c73d2 100644
> --- a/net/sched/sch_netem.c
> +++ b/net/sched/sch_netem.c
[...]
> @@ -465,24 +467,22 @@ static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch)
[...]
>
> +		if (q->rate) {
>   			delay += packet_len_2_sched_time(skb->len, q);
>   		}

    Single statements shouldn't be enclosed in {} (and scripts/checkpatch.pl 
should complain about it).

WBR, Sergei
