From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH] net: Always fire at least one linkwatch event
Date: Tue, 27 Sep 2011 15:49:35 -0400 (EDT)
Message-ID: <20110927.154935.1119264051234681851.davem@davemloft.net>
References: <1316634689-15083-1-git-send-email-nhorman@tuxdriver.com>
	<20110927.145943.1365764295978178226.davem@redhat.com>
	<20110927193413.GA30020@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jfeeney@redhat.com
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:43058 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751220Ab1I0Tur (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2011 15:50:47 -0400
In-Reply-To: <20110927193413.GA30020@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Tue, 27 Sep 2011 15:34:13 -0400

> So tg3 actually works properly upstream, but the larger issue remains - Drivers
> individually must set and clear the NOCARRIER flag in order to effectively prime
> the linkwatch state machine, which seems to me haphazard and prone to recurring
> bugs.

Driver controls when the PHY is reset, auto-negotiation is started, etc. so it is
the only entity which is in the position to set the correct state.

So we kind of depend upon drivers managing the state correctly and accurately.

If I follow what tg3 is currently doing, just to show an example, it first
sets carrier off then resets then entire chip atomically.  This reset will
restart auto-neg, etc. and trigger a subsequent link-up event which will
netif_carrier_on() and get the proper transition.
