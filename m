From: Paulius Zaleckas <paulius.zaleckas@gmail.com>
Subject: Re: [PATCH] vlan: Make it possible to add vlan with id 4095
Date: Fri, 28 Sep 2012 16:29:51 +0300
Message-ID: <5065A64F.4080507@gmail.com>
References: <20120928123258.9454.95197.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: kaber@trash.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from darkstar.wilibox.com ([85.255.61.7]:50349 "EHLO
	darkstar.wilibox.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756714Ab2I1Nhd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Sep 2012 09:37:33 -0400
In-Reply-To: <20120928123258.9454.95197.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/28/2012 03:32 PM, Paulius Zaleckas wrote:
> vconfig help tells that vlan_id should be 0-4095, but fails
> with 4095.
>
> There is an off-by-one bug while evaluating vlan_id.
> Fix it by evaluating against count(4096), not mask(0x0fff = 4095).

On the other hand 4095 is reserved by 802.1Q...

http://en.wikipedia.org/wiki/IEEE_802.1Q
VLAN Identifier (VID): a 12-bit field specifying the VLAN to which the 
frame belongs. The hexadecimal values of 0x000 and 0xFFF are reserved. 
All other values may be used as VLAN identifiers, allowing up to 4,094 
VLANs. The reserved value 0x000 indicates that the frame does not belong 
to any VLAN; in this case, the 802.1Q tag specifies only a priority and 
is referred to as a priority tag.

So maybe we should fix vconfig help?
