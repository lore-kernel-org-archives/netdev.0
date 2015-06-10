From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC,v3 02/10] dpaa_eth: add support for DPAA Ethernet
Date: Wed, 10 Jun 2015 10:56:01 -0700
Message-ID: <1433958961.27504.15.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1430319405-31280-1-git-send-email-madalin.bucur@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	linux-kernel@vger.kernel.org
To: madalin.bucur@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f179.google.com ([209.85.213.179]:33726 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754088AbbFJR4F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jun 2015 13:56:05 -0400
In-Reply-To: <1430319405-31280-1-git-send-email-madalin.bucur@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-04-29 at 17:56 +0300, Madalin Bucur wrote:
> This introduces the Freescale Data Path Acceleration Architecture
> (DPAA) Ethernet driver (dpaa_eth) that builds upon the DPAA QMan,
> BMan, PAMU and FMan drivers to deliver Ethernet connectivity on
> the Freescale DPAA QorIQ platforms.
...

> +	/* We're going to store the skb backpointer at the beginning
> +	 * of the data buffer, so we need a privately owned skb
> +	 */
> +
> +	/* Code borrowed from skb_unshare(). */
> +	if (skb_cloned(skb)) {
> +		struct sk_buff *nskb = skb_copy(skb, GFP_ATOMIC);
> +
> +		/* Finally, create a contig FD from this skb */
> +		skb_to_contig_fd(priv, skb, &fd, countptr, &offset);
> +
> +		kfree_skb(skb);
> +		skb = nskb;
> +		/* skb_copy() has now linearized the skbuff. */
> +	}
> +

You know that TCP packets are clones, right ?
This code is killing performance.

TCP allows the headers part being modified by a driver if needed.

You should use skb_header_cloned() instead.
