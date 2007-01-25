From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Fix sorting of SACK blocks
Date: Thu, 25 Jan 2007 15:55:32 -0800 (PST)
Message-ID: <20070125.155532.78711708.davem@davemloft.net>
References: <20070125182903.GA22455@galon.ev-en.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@osdl.org
To: baruch@ev-en.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37390
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1030650AbXAYXzd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jan 2007 18:55:33 -0500
In-Reply-To: <20070125182903.GA22455@galon.ev-en.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Baruch Even <baruch@ev-en.org>
Date: Thu, 25 Jan 2007 20:29:03 +0200

> The sorting of SACK blocks actually munges them rather than sort, causing the
> TCP stack to ignore some SACK information and breaking the assumption of
> ordered SACK blocks after sorting.
> 
> The sort takes the data from a second buffer which isn't moved causing
> subsequent data moves to occur from the wrong location. The fix is to
> use a temporary buffer as a normal sort does.
> 
> Signed-Off-By: Baruch Even <baruch@ev-en.org>

BTW, in reviewing this I note that there is now only one remaining
use of tp->recv_sack_cache[] and that is the code earlier in this
function which is trying to detect if all we are doing is extending
the leading edge of a SACK block.

It would be nice to be able to clear out that usage as well, and
remove recv_sack_cache[] and thus make tcp_sock smaller.
