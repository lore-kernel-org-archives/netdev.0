From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch] openvswitch: fix the calculation of checksum for vlan
 header
Date: Fri, 22 Feb 2013 17:29:52 +0800
Message-ID: <1361525392.1614.14.camel@cr0>
References: <1361510722-27831-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Jesse Gross <jesse@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:5958 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756156Ab3BVKBm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Feb 2013 05:01:42 -0500
In-Reply-To: <1361510722-27831-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-02-22 at 13:25 +0800, Cong Wang wrote:
> @@ -115,7 +115,7 @@ static int push_vlan(struct sk_buff *skb, const struct ovs_action_push_vlan *vla
>  
>  		if (skb->ip_summed == CHECKSUM_COMPLETE)
>  			skb->csum = csum_add(skb->csum, csum_partial(skb->data
> -					+ ETH_HLEN, VLAN_HLEN, 0));
> +					+ (2 * ETH_ALEN), VLAN_HLEN, 0));
>  
>  	}
>  	__vlan_hwaccel_put_tag(skb, ntohs(vlan->vlan_tci) & ~VLAN_TAG_PRESENT);

__pop_vlan_tci() has same problem...

I will resend this patch.
