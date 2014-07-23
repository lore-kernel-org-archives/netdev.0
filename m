From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCHv2] skbedit: allow the user to specify bitmask for mark
Date: Wed, 23 Jul 2014 10:16:56 -0700
Message-ID: <CAHA+R7MvxaWpybUJFZd4W0kEJE4nOMD_ApmSb0KgBkNugbttQA@mail.gmail.com>
References: <1406102589-8441-1-git-send-email-antonio@meshcoding.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	sergei.shtylyov@cogentembedded.com,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Antonio Quartulli <antonio@open-mesh.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: Antonio Quartulli <antonio@meshcoding.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f176.google.com ([209.85.217.176]:38970 "EHLO
	mail-lb0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757549AbaGWRQ5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jul 2014 13:16:57 -0400
Received: by mail-lb0-f176.google.com with SMTP id u10so1163319lbd.35
        for <netdev@vger.kernel.org>; Wed, 23 Jul 2014 10:16:56 -0700 (PDT)
In-Reply-To: <1406102589-8441-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 23, 2014 at 1:03 AM, Antonio Quartulli
<antonio@meshcoding.com> wrote:
>  #define TCA_SKBEDIT_MAX (__TCA_SKBEDIT_MAX - 1)
> diff --git a/net/sched/act_skbedit.c b/net/sched/act_skbedit.c
> index fcfeeaf..6111b06 100644
> --- a/net/sched/act_skbedit.c
> +++ b/net/sched/act_skbedit.c
> @@ -43,8 +43,12 @@ static int tcf_skbedit(struct sk_buff *skb, const struct tc_action *a,
>         if (d->flags & SKBEDIT_F_QUEUE_MAPPING &&
>             skb->dev->real_num_tx_queues > d->queue_mapping)
>                 skb_set_queue_mapping(skb, d->queue_mapping);
> -       if (d->flags & SKBEDIT_F_MARK)
> -               skb->mark = d->mark;
> +       if (d->flags & SKBEDIT_F_MARK) {
> +               /* unset all the bits in the mask */
> +               skb->mark &= ~d->mask;
> +               /* assign the mark value for the masked bit only */
> +               skb->mark |= d->mark & d->mask;

The comments are useless, code is already clear.
