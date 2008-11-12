From: Patrick Ohly <patrick.ohly@intel.com>
Subject: Re: Storing hardware timestamps - how about using the new skb's
	control block?
Date: Wed, 12 Nov 2008 09:27:18 +0100
Message-ID: <1226478438.31699.55.camel@ecld0pohly>
References: <20081112072340.1c0c1a74.nanog@85d5b20a518b8f6864949bd940457dc124746ddc.nosense.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Octavian Purdila <opurdila@ixiacom.com>
To: Mark Smith
	<nanog@85d5b20a518b8f6864949bd940457dc124746ddc.nosense.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:46945 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751428AbYKLI1W (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Nov 2008 03:27:22 -0500
In-Reply-To: <20081112072340.1c0c1a74.nanog@85d5b20a518b8f6864949bd940457dc124746ddc.nosense.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2008-11-11 at 20:53 +0000, Mark Smith wrote:
> Just a quick suggestion for storing hardware timestamps, how about
> storing them in the new skb's control block?
> 
> From what I understand, any private users of the control block are
> supposed to ignore the existing value, and if a protocol/tap is going
> to be looking at the new skb, it should have done a skb_share_check()
> first to grab it's own private copy if necessary, protecting the
> control block stored timestamp value from any of the other skb
> users who might change the control block value for their own purposes.

My understanding of sk_buff->cb might be wrong, but isn't each layer
allowed to overwrite it as the packet traverses the different queues?
skb_share_check() is not mandatory: the owner of a packet has to call it
if he wants to preserve the control block, not the recipient of a
packet.

If that understanding is correct, then I don't see how the control block
can be used to communicate information across layers. Or do I miss
something fundamental?

-- 
Best Regards, Patrick Ohly

The content of this message is my personal opinion only and although
I am an employee of Intel, the statements I make here in no way
represent Intel's position on the issue, nor am I authorized to speak
on behalf of Intel on this matter.

