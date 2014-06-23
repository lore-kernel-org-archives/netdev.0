From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] xen-netback: bookkeep number of active queues
 in our own module
Date: Mon, 23 Jun 2014 02:11:10 -0700 (PDT)
Message-ID: <20140623.021110.1153969828079234680.davem@davemloft.net>
References: <1403443901-5404-1-git-send-email-wei.liu2@citrix.com>
	<20140622.172105.1949118384610767695.davem@davemloft.net>
	<20140623084032.GU20819@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xen-devel@lists.xen.org, netdev@vger.kernel.org,
	boris.ostrovsky@oracle.com, ian.campbell@citrix.com
To: wei.liu2@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53761 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751282AbaFWJLL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jun 2014 05:11:11 -0400
In-Reply-To: <20140623084032.GU20819@zion.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Liu <wei.liu2@citrix.com>
Date: Mon, 23 Jun 2014 09:40:32 +0100

> On Sun, Jun 22, 2014 at 05:21:05PM -0700, David Miller wrote:
>> From: Wei Liu <wei.liu2@citrix.com>
>> Date: Sun, 22 Jun 2014 14:31:41 +0100
>> 
>> >  
>> > +	/* Initialisation completed, tell core driver the number of
>> > +	 * active queues.
>> > +	 */
>> > +	rtnl_lock();
>> > +	netif_set_real_num_tx_queues(be->vif->dev, requested_num_queues);
>> > +	netif_set_real_num_rx_queues(be->vif->dev, requested_num_queues);
>> > +	rtnl_unlock();
>> > +
>> >  	xenvif_carrier_on(be->vif);
>> 
>> This function _NEVER_ set the number of RX queues beforehand,
>> therefore why are you adding an RX queue adjustment now?
>> 
> 
> As I went through the core driver code I found this to be a missing call
> in previous code.
> 
> "In current Xen multiqueue design, the number of TX queues and RX queues
> are in fact the same. So we need to set the numbers of TX and RX queues
> to the same value."
> 
> Does the above paragraph answers your question? If so, I will add it to
> commit message and resend this patch.

Yes.
