From: David Miller <davem@davemloft.net>
Subject: Re: flow director and packet ordering
Date: Tue, 16 Jun 2009 02:31:32 -0700 (PDT)
Message-ID: <20090616.023132.194401812.davem@davemloft.net>
References: <20090615.020738.243788769.davem@davemloft.net>
	<Pine.WNT.4.64.0906152327070.7160@ppwaskie-MOBL2.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeffrey.t.kirsher@intel.com,
	jesse.brandeburg@intel.com
To: peter.p.waskiewicz.jr@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37283
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751213AbZFPJb3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jun 2009 05:31:29 -0400
In-Reply-To: <Pine.WNT.4.64.0906152327070.7160@ppwaskie-MOBL2.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Date: Mon, 15 Jun 2009 23:42:16 -0700 (Pacific Daylight Time)

> The way the internal hashing works in the software and hardware, I think 
> we're pretty safe with getting moved unexpectedely.

The device RX being empty doesn't mean anything.

Those packets, even after you give them all to netif_receive_skb(),
can be held up in all number of queues, or even scheduled off to be
processed by ksoftirqd after a full context switch.

In the meantime you cannot switch the RX queue mapping without
introducing reordering.

So my original fears and doubts still stand :-)
