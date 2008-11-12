From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH 06/13] workaround: detect time stamp when command
 flags are expected
Date: Wed, 12 Nov 2008 02:00:43 -0800 (PST)
Message-ID: <20081112.020043.97055918.davem@davemloft.net>
References: <1226414697.17450.852.camel@ecld0pohly>
	<1226415426.31699.5.camel@ecld0pohly>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, opurdila@ixiacom.com,
	shemminger@vyatta.com, netdev@axxeo.de, ak@linux.intel.com,
	john.ronciak@intel.com, dada1@cosmosbay.com, oliver@hartkopp.net
To: patrick.ohly@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51255
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751447AbYKLKAo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Nov 2008 05:00:44 -0500
In-Reply-To: <1226415426.31699.5.camel@ecld0pohly>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick Ohly <patrick.ohly@intel.com>
Date: Wed, 29 Oct 2008 15:48:48 +0100

> +	/* sanity check: extra bits set => might be a real time stamp */
> +	if (orig_skb->tstamp.tv64 & ~(SKB_TSTAMP_TX_HARDWARE|SKB_TSTAMP_TX_HARDWARE_IN_PROGRESS|SKB_TSTAMP_TX_SOFTWARE)) {

Line is way too long, split up and group the bits:

	if (orig_skb->tstamp.tv64 & ~(SKB_TSTAMP_TX_HARDWARE |
				      SKB_TSTAMP_TX_HARDWARE_IN_PROGRESS |
				      SKB_TSTAMP_TX_SOFTWARE)) {
