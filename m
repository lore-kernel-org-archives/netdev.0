From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] bonding 802.3ad: Fix the state machine locking v2
Date: Mon, 07 Mar 2011 16:03:15 -0800 (PST)
Message-ID: <20110307.160315.13736027.davem@davemloft.net>
References: <1299226152-23578-1-git-send-email-nils.carlson@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, andy@greyhouse.net, netdev@vger.kernel.org
To: nils.carlson@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35128
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750754Ab1CHACi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2011 19:02:38 -0500
In-Reply-To: <1299226152-23578-1-git-send-email-nils.carlson@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nils Carlson <nils.carlson@ericsson.com>
Date: Fri, 4 Mar 2011 09:09:11 +0100

> Changes since v1:
> * Clarify an unclear comment
> * Move a (possible) name change to a separate patch
> 
> The ad_rx_machine, ad_periodic_machine and ad_port_selection_logic
> functions all inspect and alter common fields within the port structure.
> Previous to this patch, only the ad_rx_machines were mutexed, and the
> periodic and port_selection could run unmutexed against an ad_rx_machine
> trigged by an arriving LACPDU.
> 
> This patch remedies the situation by protecting all the state machines
> from concurrency. This is accomplished by locking around all the state
> machines for a given port, which are executed at regular intervals; and
> the ad_rx_machine when handling an incoming LACPDU.
> 
> Signed-off-by: Nils Carlson <nils.carlson@ericsson.com>

Applied.
