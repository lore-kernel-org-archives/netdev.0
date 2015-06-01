From: Ivan Mikhaylov <ivan@ru.ibm.com>
Subject: Re: [PATCH] ethtool: changes of emac_regs structure accordingly
 within driver emac_regs structure.
Date: Mon, 1 Jun 2015 16:30:57 +0400
Message-ID: <20150601163057.01717aef@fr-ThinkPad-W520>
References: <20150521190917.6971eb09@fr-ThinkPad-W520>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp15.uk.ibm.com ([195.75.94.111]:59062 "EHLO
	e06smtp15.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751425AbbFAN2w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2015 09:28:52 -0400
Received: from /spool/local
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <ivan@ru.ibm.com>;
	Mon, 1 Jun 2015 14:28:50 +0100
In-Reply-To: <20150521190917.6971eb09@fr-ThinkPad-W520>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 1 June 2015 12:57 +0400
Ben Hutchings <ben@decadent.org.uk> wrote:

>On Thu, 2015-05-21 at 19:09 +0400, Ivan Mikhaylov wrote:
>> In ibm_emac.c in ethtool size of emac structure which passing through
>> to driver is nailed down and not correlating with current emac_regs
>> structure.
>> 
>> Signed-off-by: Ivan Mikhaylov <ivan@ru.ibm.com>
>[...]
>
>This is not backward-compatible.  It ought to be possible to mix and
>match old and new ethtool and driver, except for the EMAC4SYNC case
>which has been broken up until now.
>
>Using the new definition of struct emac_regs, I think the driver and
>ethtool need to agree that the MAC register dump sizes are:
>
>EMAC:      offsetof(struct emac_regs, u1)
>EMAC4:     offsetof(struct emac_regs, u1.emac4) + sizeof(p->u1.emac4)
>EMAC4SYNC: offsetof(struct emac_regs, u1.emac4sync) +
>sizeof(p->u1.emac4sync)
>
>Ben.
>
>-- 
>Ben Hutchings
>Reality is just a crutch for people who can't handle science fiction.

Actually it is backward-compatible because we don't care about size
which is coming from driver side, only what we doing is map of driver
structure to ethtool structure and results will be same
for emac and emac4.

 struct emac_regs *p = (struct emac_regs *)(hdr + 1);

Also size which you mentioned (112 emac, 116 emac4) can be different
from what you saying cause this managed by dts files where we can set
something like 0x100 or 0x80 for this memory area and we will still
have problem in representing MII area if this size wasn't set right
in dts.

Ethtool will be work in same way even if we have emac or emac4.

Thank you for respond!
