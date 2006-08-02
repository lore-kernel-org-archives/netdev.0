From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [RFC] gre: transparent ethernet bridging
Date: Wed, 2 Aug 2006 10:23:37 -0700
Message-ID: <20060802102337.7ba32020@dxpl.pdx.osdl.net>
References: <44CDD631.5030008@snapgear.com>
	<20060731091423.3327f85e@dxpl.pdx.osdl.net>
	<44CEAB31.5090501@snapgear.com>
	<20060731220822.444f04e4@localhost.localdomain>
	<44CF1EF8.2090800@snapgear.com>
	<44D04386.2040705@snapgear.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:10975 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932108AbWHBRXp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Aug 2006 13:23:45 -0400
To: Philip Craig <philipc@snapgear.com>
In-Reply-To: <44D04386.2040705@snapgear.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 02 Aug 2006 16:17:42 +1000
Philip Craig <philipc@snapgear.com> wrote:

> > Stephen Hemminger wrote:
> >> I am not against making the bridge code smarter to handle other
> >> encapsulation.
> 
> Here's an updated patch that fixes all issues I am aware of.
> 
> It generates a random mac address for gre ports, and also stores
> a copy of the mac address for ethernet ports, rather than checking
> dev->type everywhere.

That looks cleaner. I wonder if using a fixed OUI would be better
than random addresses but then choosing an OUI would be a problem.

You probably should add a comment about what this function is doing, 
and why.

> static int __br_nf_dev_queue_xmit(struct sk_buff *skb)
> +{
> +	if (skb->dst == (struct dst_entry *)&__fake_rtable) {
> +		dst_release(skb->dst);
> +		skb->dst = NULL;
> +	}
> +
> +	return br_dev_queue_push_xmit(skb);
> +}
> +
