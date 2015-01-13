From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next v2 2/2] vxlan: Remote checksum offload
Date: Tue, 13 Jan 2015 01:26:26 +0000
Message-ID: <20150113012626.GD20387@casper.infradead.org>
References: <1421110838-5146-1-git-send-email-therbert@google.com>
 <1421110838-5146-3-git-send-email-therbert@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:48757 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751789AbbAMB01 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2015 20:26:27 -0500
Content-Disposition: inline
In-Reply-To: <1421110838-5146-3-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/12/15 at 05:00pm, Tom Herbert wrote:
> +	if ((flags & VXLAN_HF_RCO) && (vs->flags & VXLAN_F_REMCSUM_RX)) {
> +		vxh = vxlan_remcsum(skb, vxh, sizeof(struct vxlanhdr), vni);
> +		if (!vxh)
> +			goto drop;
> +
> +		flags &= ~VXLAN_HF_RCO;
> +		vni &= VXLAN_VID_MASK;
> +	}

Nice.

Would you mind basing this on top off the extension framework being put
in place by GBP? I think that all VXLAN extensions should be exposed as
such in a universal way to user space.
