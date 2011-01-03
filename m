From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V4] bridge: fix br_multicast_ipv6_rcv for paged skbs
Date: Mon, 03 Jan 2011 11:29:26 -0800 (PST)
Message-ID: <20110103.112926.48505128.davem@davemloft.net>
References: <1294051080-29492-1-git-send-email-tomas.winkler@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, johannes@sipsolutions.net,
	shemminger@vyatta.com
To: tomas.winkler@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34826
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751285Ab1ACT2z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jan 2011 14:28:55 -0500
In-Reply-To: <1294051080-29492-1-git-send-email-tomas.winkler@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tomas Winkler <tomas.winkler@intel.com>
Date: Mon,  3 Jan 2011 12:37:59 +0200

> use pskb_may_pull to access ipv6 header correctly for paged skbs
> It was omitted in the bridge code leading to crash in blind
> __skb_pull
> 
> since the skb is cloned undonditionally we also simplify the
> the exit path
> 
> this fixes bug https://bugzilla.kernel.org/show_bug.cgi?id=25202
 ...
> Cc: David Miller <davem@davemloft.net>
> Cc: Johannes Berg <johannes@sipsolutions.net>
> Cc: Stephen Hemminger <shemminger@vyatta.com>
> Signed-off-by: Tomas Winkler <tomas.winkler@intel.com>

Looks good, applied thanks Tomas.

There are several simplifications we can make in the net-next-2.6
tree.

Most of this code just wants the query type and then optionally
the ipv6 address the operation applies to.  For such simple value
fetching, skb_header_pointer() is probably ideal compared to
all of this pskb_may_pull() business.
