From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next v2 2/2] vxlan: support GPE/NSH
Date: Mon, 15 Feb 2016 17:49:17 +0100
Message-ID: <20160215174917.025b066c@griffin>
References: <1455220626-28244-1-git-send-email-brussell@brocade.com>
	<1455220626-28244-3-git-send-email-brussell@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Brian Russell <brussell@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49755 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751635AbcBOQtU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Feb 2016 11:49:20 -0500
In-Reply-To: <1455220626-28244-3-git-send-email-brussell@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 11 Feb 2016 19:57:06 +0000, Brian Russell wrote:
> +skip_l2:
>  	skb_reset_network_header(skb);
> +
>  	/* In flow-based mode, GBP is carried in dst_metadata */
> -	if (!(vs->flags & VXLAN_F_COLLECT_METADATA))
> +	if (!(vs->flags & VXLAN_F_COLLECT_METADATA) &&
> +	    !(vs->flags & VXLAN_F_GPE))
>  		skb->mark = md->gbp;

This is completely wrong. You cannot return a packet with a garbage in
place of the Ethernet header from ARPHRD_ETHER interface. For proper
VXLAN-GPE support, the vxlan interface needs to be in L3 mode, e.g.
ARPHRD_NONE.

To support L3 mode, the vxlan driver needs *tons* of cleanups (or tons
of duplicate code). This is exactly what I've done and what I'm in
process of merging. The number of patches is too big to be submitted as
a single patchset, hence I'm submitting in parts. The first one has
been already merged (net-next commit 19f76f63507f). For the full code,
look at: https://github.com/jbenc/linux-vxlan/commits/master

Comments are welcome.

 Jiri

-- 
Jiri Benc
