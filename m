From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 2/5] ixgbe: increase default TX ring buffer to
 1024
Date: Wed, 14 May 2014 15:54:37 -0400 (EDT)
Message-ID: <20140514.155437.750583011696684472.davem@davemloft.net>
References: <537399C2.8070908@intel.com>
	<20140514.134950.1208688313542719676.davem@davemloft.net>
	<20140514210935.5fc80c79@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@intel.com, netdev@vger.kernel.org,
	jeffrey.t.kirsher@intel.com, dborkman@redhat.com, fw@strlen.de,
	shemminger@vyatta.com, paulmck@linux.vnet.ibm.com,
	robert@herjulf.se, greearb@candelatech.com,
	john.r.fastabend@intel.com, danieltt@kth.se, zhouzhouyi@gmail.com
To: brouer@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53894 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751173AbaENTyk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2014 15:54:40 -0400
In-Reply-To: <20140514210935.5fc80c79@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Wed, 14 May 2014 21:09:35 +0200

> On Wed, 14 May 2014 13:49:50 -0400 (EDT)
> David Miller <davem@davemloft.net> wrote:
> 
>> From: Alexander Duyck <alexander.h.duyck@intel.com>
>> Date: Wed, 14 May 2014 09:28:50 -0700
>> 
>> > I'd say that it might be better to just add a note to the documentation
>> > folder indicating what configuration is optimal for pktgen rather then
>> > changing everyone's defaults to support one specific test.
>> 
>> We could have drivers provide a pktgen config adjustment mechanism,
>> so if someone starts pktgen then the device auto-adjusts to a pktgen
>> optimal configuration (whatever that may entail).
> 
> That might be problematic because changing the TX queue size cause the
> ixgbe driver to reset the link.

A minor issue for someone firing up a specialized network test tool
like pktgen.

> Notice that pktgen is ignoring BQL.  I'm sort of hoping that BQL will
> push back for real use-cases, to avoid the bad effects of increasing
> the TX size.

I think we need to think carefully about drivers configuring such huge
per-queue TX queue sizes.

If anything, we should be decreasing their size in the default
configuration.
