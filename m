From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next v2 2/2] vxlan: Remote checksum offload
Date: Tue, 13 Jan 2015 11:44:43 +0000
Message-ID: <20150113114443.GK20387@casper.infradead.org>
References: <1421110838-5146-1-git-send-email-therbert@google.com>
 <1421110838-5146-3-git-send-email-therbert@google.com>
 <20150113012626.GD20387@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:51427 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751865AbbAMLoo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2015 06:44:44 -0500
Content-Disposition: inline
In-Reply-To: <20150113012626.GD20387@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/13/15 at 01:26am, Thomas Graf wrote:
> On 01/12/15 at 05:00pm, Tom Herbert wrote:
> > +	if ((flags & VXLAN_HF_RCO) && (vs->flags & VXLAN_F_REMCSUM_RX)) {
> > +		vxh = vxlan_remcsum(skb, vxh, sizeof(struct vxlanhdr), vni);
> > +		if (!vxh)
> > +			goto drop;
> > +
> > +		flags &= ~VXLAN_HF_RCO;
> > +		vni &= VXLAN_VID_MASK;
> > +	}
> 
> Nice.
> 
> Would you mind basing this on top off the extension framework being put
> in place by GBP? I think that all VXLAN extensions should be exposed as
> such in a universal way to user space.

Doing so would also fix the missing "don't share UDP port on extension
mismatch" functionality as explained in "[PATCH 2/6] vxlan: Group Policy
extension".
