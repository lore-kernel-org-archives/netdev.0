From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v4 net-next 1/1] net_sched: Introduce skbmod action
Date: Mon, 12 Sep 2016 14:58:34 -0700
Message-ID: <1473717514.18970.80.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1473713206-2450-1-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        xiyou.wangcong@gmail.com, daniel@iogearbox.net,
        john.r.fastabend@intel.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:34701 "EHLO
        mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752078AbcILV6h (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Sep 2016 17:58:37 -0400
Received: by mail-pf0-f170.google.com with SMTP id p64so56508521pfb.1
        for <netdev@vger.kernel.org>; Mon, 12 Sep 2016 14:58:36 -0700 (PDT)
In-Reply-To: <1473713206-2450-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-09-12 at 16:46 -0400, Jamal Hadi Salim wrote:
> From: Jamal Hadi Salim <jhs@mojatatu.com>

> +
> +	/* XXX: if you are going to edit more fields beyond ethernet header
> +	 * (example when you add IP header replacement or vlan swap)
> +	 * then MAX_EDIT_LEN needs to change appropriately
> +	*/
> +	err = skb_ensure_writable(skb, ETH_HLEN);
> +	if (unlikely(err)) /* best policy is to drop on the floor */
> +		action = TC_ACT_SHOT;
> +
> +	rcu_read_lock();
> +	action = READ_ONCE(d->tcf_action);

You are overwriting @action, while you might have put TC_ACT_SHOT in it
3 lines above.

Maybe you meant :
	if (err)
		return TC_ACT_SHOT;
