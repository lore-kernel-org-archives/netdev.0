From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC v3 2/2] iwlwifi: mvm: send large SKBs to the transport
Date: Thu, 22 Oct 2015 05:03:26 -0700
Message-ID: <1445515406.22974.107.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1445452464-19525-1-git-send-email-emmanuel.grumbach@intel.com>
	 <1445452464-19525-3-git-send-email-emmanuel.grumbach@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	sara.sharon@intel.com, ido@wizery.com
To: Emmanuel Grumbach <emmanuel.grumbach@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:35806 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757257AbbJVMD3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Oct 2015 08:03:29 -0400
In-Reply-To: <1445452464-19525-3-git-send-email-emmanuel.grumbach@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-10-21 at 21:34 +0300, Emmanuel Grumbach wrote:
> +
> +		if (skb->protocol == htons(ETH_P_IP)) {
> +			ip_hdr(tmp)->id = ip_hdr(skb)->id;

Too late, you already called consume_skb(skb).
So this is a potential use after free.

> +			be16_add_cpu(&ip_hdr(tmp)->id, i * num_subframes);
> +		}
> +


I would use 

base_id = ip_hdr(skb)->id; // before the consume_skb(skb)

ip_hdr(tmp)->id = htons(base_id + i * num_subframes);
