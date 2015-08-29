From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [net-next PATCH 3/4] net: sched: register noqueue qdisc
Date: Sat, 29 Aug 2015 23:04:45 +0300
Message-ID: <55E2105D.2060602@cogentembedded.com>
References: <1440703299-21243-1-git-send-email-phil@nwl.cc>
 <1440703299-21243-4-git-send-email-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, eric.dumazet@gmail.com, brouer@redhat.com,
	geert@linux-m68k.org
To: Phil Sutter <phil@nwl.cc>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f182.google.com ([209.85.217.182]:34500 "EHLO
	mail-lb0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752204AbbH2UEs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Aug 2015 16:04:48 -0400
Received: by lbbtg9 with SMTP id tg9so44950774lbb.1
        for <netdev@vger.kernel.org>; Sat, 29 Aug 2015 13:04:46 -0700 (PDT)
In-Reply-To: <1440703299-21243-4-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 8/27/2015 10:21 PM, Phil Sutter wrote:

> This way users can attach noqueue just like any other qdisc using tc
> without having to mess with tx_queue_len first.
>
> Signed-off-by: Phil Sutter <phil@nwl.cc>
> ---
>   include/net/sch_generic.h |  1 +
>   net/sched/sch_api.c       |  1 +
>   net/sched/sch_generic.c   | 12 +++++++++++-
>   3 files changed, 13 insertions(+), 1 deletion(-)

[...]
> diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
> index f501b74..d5c7c0d 100644
> --- a/net/sched/sch_generic.c
> +++ b/net/sched/sch_generic.c
> @@ -416,9 +416,19 @@ struct Qdisc noop_qdisc = {
>   };
>   EXPORT_SYMBOL(noop_qdisc);
>
> -static struct Qdisc_ops noqueue_qdisc_ops __read_mostly = {
> +static int noqueue_init(struct Qdisc *qdisc, struct nlattr *opt)
> +{
> +	/* register_qdisc() assigns a default of noop_enqueue if unset,
> +	 * but __dev_queue_xmit() treats noqueue only as such
> +	 * if this is NULL - so clear it here. */

    The multi-line comments in the networking code should follow this style:

/* bla
  * bla
  */

[...]

MBR, Sergei
