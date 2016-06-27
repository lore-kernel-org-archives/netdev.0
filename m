From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next v10 2/5] openvswitch: set skb protocol and
 mac_len when receiving on internal device
Date: Mon, 27 Jun 2016 11:35:30 +0200
Message-ID: <20160627113530.00b6864d@griffin>
References: <1464848686-7656-1-git-send-email-simon.horman@netronome.com>
	<1464848686-7656-3-git-send-email-simon.horman@netronome.com>
	<CAOrHB_Aqdkr-26GxGh=W0AsojOMzDXYf5zif=kaFbWBty5uHKA@mail.gmail.com>
	<20160607030809.GE31696@vergenet.net>
	<CAOrHB_Cp4bw1beQb8tCk+cR9k2Nv5kBMVD-a8SYRVkOeeQYJvA@mail.gmail.com>
	<20160617055331.GA24833@vergenet.net>
	<CAOrHB_BWfLk8yba2XkF43Hm-czGUZnVWQQ=HW3-vvpFEH7GNpA@mail.gmail.com>
	<20160621022458.GA28358@vergenet.net>
	<CAOrHB_B2mUqUOgwZroRqaYwsHCKd-Vj5nMWMvPxfF=quxhJ2cA@mail.gmail.com>
	<20160623020436.GA28594@vergenet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: pravin shelar <pshelar@ovn.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	ovs dev <dev@openvswitch.org>
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54394 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750736AbcF0Jff (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Jun 2016 05:35:35 -0400
In-Reply-To: <20160623020436.GA28594@vergenet.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 23 Jun 2016 11:04:38 +0900, Simon Horman wrote:
> I think you are right as IIRC the call to skb_reset_mac_header was
> added for this use-case. Its unfortunate that we can't use it in
> internal_dev_xmit() because of loosing track of MPLS as you mentioned
> earlier. But it does seem that setting mac_header to ~0 works well
> in conjunction with updates to OvS posted earlier in this sub-therad.
> 
> I have the following working. Jiri, is the ip_gre portion acceptable to you?

Sorry for the late reply, I was off the last week.

> diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
> index 58d323289872..e6772b6934a3 100644
> --- a/net/ipv4/ip_gre.c
> +++ b/net/ipv4/ip_gre.c
> @@ -279,7 +279,7 @@ static int __ipgre_rcv(struct sk_buff *skb, const struct tnl_ptk_info *tpi,
>  		if (tunnel->dev->type != ARPHRD_NONE)
>  			skb_pop_mac_header(skb);
>  		else
> -			skb_reset_mac_header(skb);
> +			skb->mac_header = (typeof(skb->mac_header))~0U;

Looks good. We should introduce a helper for this, though
(skb_unset_mac_header or so).

Thanks!

 Jiri
