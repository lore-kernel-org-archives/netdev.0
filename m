From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bonding: reset queue mapping prior to transmission to
 physical device (v5)
Date: Sun, 05 Jun 2011 14:32:35 -0700 (PDT)
Message-ID: <20110605.143235.545319481813491859.davem@davemloft.net>
References: <1307129073-3769-1-git-send-email-nhorman@tuxdriver.com>
	<1307133352-4111-1-git-send-email-nhorman@tuxdriver.com>
	<26637.1307143866@death>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, netdev@vger.kernel.org, andy@greyhouse.net
To: fubar@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:47269 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756129Ab1FEVdq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Jun 2011 17:33:46 -0400
In-Reply-To: <26637.1307143866@death>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jay Vosburgh <fubar@us.ibm.com>
Date: Fri, 03 Jun 2011 16:31:06 -0700

> Neil Horman <nhorman@tuxdriver.com> wrote:
> 
>>The bonding driver is multiqueue enabled, in which each queue represents a slave
>>to enable optional steering of output frames to given slaves against the default
>>output policy.  However, it needs to reset the skb->queue_mapping prior to
>>queuing to the physical device or the physical slave (if it is multiqueue) could
>>wind up transmitting on an unintended tx queue
>>
>>Change Notes:
>>v2) Based on first pass review, updated the patch to restore the origional queue
>>mapping that was found in bond_select_queue, rather than simply resetting to
>>zero.  This preserves the value of queue_mapping when it was set on receive in
>>the forwarding case which is desireable.
>>
>>v3) Fixed spelling an casting error in skb->cb
>>
>>v4) fixed to store raw queue_mapping to avoid double decrement
>>
>>v5) Eric D requested that ->cb access be wrapped in a macro.
> 
> 	Shouldn't the change log go below the "---" so it doesn't end up
> in the git commit log?

Yes, usually, however in this case Neil's change notes give some
important information about why the patch is implemented the way it
is, especially the notes about "v2" so I left them in the commit
message.

> 	In any event, I looked for ways into bond_dev_queue_xmit without
> first passing through bond_select_queue (lest stale cb[] data intrude),
> and I don't see any, so I think this is ok.
> 
> Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>

Applied, thanks everyone.
