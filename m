From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: Re: [PATCH net-next V3 4/4] net/sched: Introduce act_tunnel_key
Date: Thu, 25 Aug 2016 19:52:56 +0300
Message-ID: <20160825195256.5ea52610@halley>
References: <1472141627-27339-1-git-send-email-hadarh@mellanox.com>
        <1472141627-27339-5-git-send-email-hadarh@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Jiri Pirko <jiri@mellanox.com>, Jiri Benc <jbenc@redhat.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Tom Herbert <tom@herbertland.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Amir Vadai <amirva@mellanox.com>, Amir Vadai <amir@vadai.me>
To: Hadar Hen Zion <hadarh@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:34998 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752152AbcHYQxD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 Aug 2016 12:53:03 -0400
Received: by mail-wm0-f66.google.com with SMTP id i5so8185332wmg.2
        for <netdev@vger.kernel.org>; Thu, 25 Aug 2016 09:53:02 -0700 (PDT)
In-Reply-To: <1472141627-27339-5-git-send-email-hadarh@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Thu, 25 Aug 2016 19:13:47 +0300 Hadar Hen Zion <hadarh@mellanox.com> wrote:
> +static int tunnel_key_act(struct sk_buff *skb, const struct tc_action *a,
> +			  struct tcf_result *res)
> +{
> +	struct tcf_tunnel_key *t = to_tunnel_key(a);
> +	int action;
> +
> +	spin_lock(&t->tcf_lock);
> +	tcf_lastuse_update(&t->tcf_tm);
> +	bstats_update(&t->tcf_bstats, skb);
> +	action = t->tcf_action;
> +
> +	switch (t->tcft_action) {
> +	case TCA_TUNNEL_KEY_ACT_RELEASE:
> +		skb_dst_set_noref(skb, NULL);
> +		break;
> +	case TCA_TUNNEL_KEY_ACT_SET:
> +		skb_dst_set_noref(skb, &t->tcft_enc_metadata->dst);
> +		break;

Two additional questions:
 - No need to perform a 'skb_dst_drop(skb)' prior the dst set calls?
 - Why there's no need to take a reference on tcft_enc_metadata->dst?

Besides that,

Reviewed-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>

Thanks!
