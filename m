From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: Re: [PATCH net-next 4/4] net_sched: act_vlan: Add priority option
Date: Fri, 12 Aug 2016 11:18:42 +0300
Message-ID: <20160812111842.12c38ed3@halley>
References: <1470835943-9042-1-git-send-email-hadarh@mellanox.com>
	<1470835943-9042-5-git-send-email-hadarh@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Jiri Pirko <jiri@mellanox.com>,
	Tom Herbert <tom@herbertland.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>
To: Hadar Hen Zion <hadarh@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:35371 "EHLO
	mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752348AbcHLISt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Aug 2016 04:18:49 -0400
Received: by mail-wm0-f67.google.com with SMTP id i5so1505258wmg.2
        for <netdev@vger.kernel.org>; Fri, 12 Aug 2016 01:18:49 -0700 (PDT)
In-Reply-To: <1470835943-9042-5-git-send-email-hadarh@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Wed, 10 Aug 2016 16:32:23 +0300 Hadar Hen Zion <hadarh@mellanox.com> wrote:
> @@ -181,7 +188,9 @@ static int tcf_vlan_dump(struct sk_buff *skb, struct tc_action *a,
>  	if (v->tcfv_action == TCA_VLAN_ACT_PUSH &&
>  	    (nla_put_u16(skb, TCA_VLAN_PUSH_VLAN_ID, v->tcfv_push_vid) ||
>  	     nla_put_be16(skb, TCA_VLAN_PUSH_VLAN_PROTOCOL,
> -			  v->tcfv_push_proto)))
> +			  v->tcfv_push_proto) ||
> +	     (v->tcfv_push_prio && nla_put_u8(skb, TCA_VLAN_PUSH_VLAN_PRIORITY,
> +					      v->tcfv_push_prio))))
>  		goto nla_put_failure;

nit: We could avoid the 'v->tcfv_push_prio' test, so user can explicitly
observe the associated priority, even if it is set to zero.

Reviewed-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>
