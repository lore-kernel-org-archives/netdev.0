From: David Miller <davem@davemloft.net>
Subject: Re: Storing hardware timestamps - how about using the new skb's
 control block?
Date: Wed, 12 Nov 2008 00:39:27 -0800 (PST)
Message-ID: <20081112.003927.153710640.davem@davemloft.net>
References: <20081112072340.1c0c1a74.nanog@85d5b20a518b8f6864949bd940457dc124746ddc.nosense.org>
	<1226478438.31699.55.camel@ecld0pohly>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nanog@85d5b20a518b8f6864949bd940457dc124746ddc.nosense.org,
	netdev@vger.kernel.org, opurdila@ixiacom.com
To: patrick.ohly@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44905
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751278AbYKLIj2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Nov 2008 03:39:28 -0500
In-Reply-To: <1226478438.31699.55.camel@ecld0pohly>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick Ohly <patrick.ohly@intel.com>
Date: Wed, 12 Nov 2008 09:27:18 +0100

> My understanding of sk_buff->cb might be wrong, but isn't each layer
> allowed to overwrite it as the packet traverses the different queues?

Right.

> skb_share_check() is not mandatory:

And besides, skb_share_check() doesn't check if somebody "owns" the
skb->cb[]

And if you bump the reference count or something silly like that to
get skb_share_check() to copy the packet, every single locally
destined TCP packet will be copied.  That will effectively kill
performance.

