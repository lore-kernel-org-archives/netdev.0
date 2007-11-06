From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 1/2] NET: Re-add VLAN tag for devices incapable of keeping
 it
Date: Tue, 06 Nov 2007 01:21:09 +0100
Message-ID: <472FB375.1020802@trash.net>
References: <472A6089.7020104@hp.com>	<18223.22291.622615.129374@zeus.sw.starentnetworks.com>	<472F5A33.20906@trash.net> <20071105.151544.175839612.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: djohnson+linux-kernel@sw.starentnetworks.com,
	jes@trained-monkey.org, mchan@broadcom.com, ram.vepa@neterion.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	bguo@sw.starentnetworks.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:48087 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752782AbXKFAV0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Nov 2007 19:21:26 -0500
In-Reply-To: <20071105.151544.175839612.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Patrick McHardy <kaber@trash.net>
> Date: Mon, 05 Nov 2007 19:00:19 +0100
> 
>> This looks like a rather expensive operation for the unlikely case
>> that packets will be received by a packet socket. IMO it should only
>> be reconstructed if actually needed, by af_packet itself.
> 
> Completely agreed.  We should not do this by default when %99
> of the networking stack simply does not care about this.


I think there is one more case that matters, which is briding
from a device with VLAN stripping for a VLAN not configured
locally. The tag will be stripped and will be lost for forwarded
packets. But I'm not exactly sure this really can be configured
(time for bed so I'll check tommorrow).

>> As we discussed some time back storing the VLAN tag in the CB on
>> TX clashes with other users of the CB like qdiscs, so we need a
>> new field in the skb for this anyway.
> 
> Someone will have to find a way to remove some other fields in
> sk_buff before I'm going to allow more space to be eaten up
> by this completely fringe case feature.


We have a two byte hole after tc_verd where we could fit this in.
But I'm pretty sure we also could reuse some other fields on input,
like queue_mapping or maybe even destructor for unowned skbs.

