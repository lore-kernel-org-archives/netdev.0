From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] NET: Re-add VLAN tag for devices incapable of
 keeping it
Date: Mon, 05 Nov 2007 16:35:42 -0800 (PST)
Message-ID: <20071105.163542.157789854.davem@davemloft.net>
References: <472F5A33.20906@trash.net>
	<20071105.151544.175839612.davem@davemloft.net>
	<472FB375.1020802@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: djohnson+linux-kernel@sw.starentnetworks.com,
	jes@trained-monkey.org, mchan@broadcom.com, ram.vepa@neterion.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	bguo@sw.starentnetworks.com
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34750
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752750AbXKFAfv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Nov 2007 19:35:51 -0500
In-Reply-To: <472FB375.1020802@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Tue, 06 Nov 2007 01:21:09 +0100

> David Miller wrote:
> > From: Patrick McHardy <kaber@trash.net>
> > Date: Mon, 05 Nov 2007 19:00:19 +0100
> > 
> >> This looks like a rather expensive operation for the unlikely case
> >> that packets will be received by a packet socket. IMO it should only
> >> be reconstructed if actually needed, by af_packet itself.
> > 
> > Completely agreed.  We should not do this by default when %99
> > of the networking stack simply does not care about this.
> 
> 
> I think there is one more case that matters, which is briding
> from a device with VLAN stripping for a VLAN not configured
> locally. The tag will be stripped and will be lost for forwarded
> packets. But I'm not exactly sure this really can be configured
> (time for bed so I'll check tommorrow).

If so then when such rules are loaded, just like PF_PACKET, it can set
the indication to start reconstituting VLAN headers stripped by HW.

> >> As we discussed some time back storing the VLAN tag in the CB on
> >> TX clashes with other users of the CB like qdiscs, so we need a
> >> new field in the skb for this anyway.
> > 
> > Someone will have to find a way to remove some other fields in
> > sk_buff before I'm going to allow more space to be eaten up
> > by this completely fringe case feature.
> 
> We have a two byte hole after tc_verd where we could fit this in.
> But I'm pretty sure we also could reuse some other fields on input,
> like queue_mapping or maybe even destructor for unowned skbs.

Two bytes is enough, so if there is a hole we can use it.
