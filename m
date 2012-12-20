From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: Re: [PATCH net-next V4 04/13] bridge: Verify that a vlan is allowed
 to egress on give port
Date: Thu, 20 Dec 2012 16:28:57 +0200
Message-ID: <20121220162857.2768f82b@pixies.home.jungo.com>
References: <1355939304-21804-1-git-send-email-vyasevic@redhat.com>
	<1355939304-21804-5-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com, davem@davemloft.net,
	or.gerlitz@gmail.com, jhs@mojatatu.com, mst@redhat.com,
	erdnetdev@gmail.com, jiri@resnulli.us
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:58215 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751181Ab2LTO3F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Dec 2012 09:29:05 -0500
Received: by mail-wi0-f179.google.com with SMTP id o1so2022148wic.12
        for <netdev@vger.kernel.org>; Thu, 20 Dec 2012 06:29:02 -0800 (PST)
In-Reply-To: <1355939304-21804-5-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Vlad,

On Wed, 19 Dec 2012 12:48:15 -0500 Vlad Yasevich <vyasevic@redhat.com> wrote:
>  /* Don't forward packets to originating port or forwarding diasabled */
>  static inline int should_deliver(const struct net_bridge_port *p,
>  				 const struct sk_buff *skb)
>  {
>  	return (((p->flags & BR_HAIRPIN_MODE) || skb->dev != p->dev) &&
> +		br_allowed_egress(p, skb) &&
>  		p->state == BR_STATE_FORWARDING);
>  }

This should be also encorporated into 'br_pass_frame_up' somehow.

Egress permission when leaving the bridge towards IP stack ("egress"
on the "bridge master port" from bridging point-of-view) should be
validated according to master port's membership.

Regards,
Shmulik
