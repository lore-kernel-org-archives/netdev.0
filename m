From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net-next 03/10] tipc: sk_recv_queue size check only for
 connectionless sockets
Date: Fri, 7 Dec 2012 14:20:30 -0500
Message-ID: <20121207192030.GA30339@hmsreliant.think-freely.org>
References: <1354890498-6448-1-git-send-email-paul.gortmaker@windriver.com>
 <1354890498-6448-4-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Jon Maloy <jon.maloy@ericsson.com>,
	Ying Xue <ying.xue@windriver.com>
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:42638 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752145Ab2LGTUl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Dec 2012 14:20:41 -0500
Content-Disposition: inline
In-Reply-To: <1354890498-6448-4-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 07, 2012 at 09:28:11AM -0500, Paul Gortmaker wrote:
> From: Ying Xue <ying.xue@windriver.com>
> 
> The sk_receive_queue limit control is currently performed for
> all arriving messages, disregarding socket and message type.
> But for connected sockets this check is redundant, since the protocol
> flow control already makes queue overflow impossible.
> 
Can you explain where that occurs?  I see where the tipc dispatch function calls
sk_add_backlog, which checks the per socket recieve queue (regardless of weather
the receiving socket is connection oriented or connectionless), but if the
receiver doesn't call receive very often, This just adds a check against your
global limit, doing nothing for your per-socket limits.  In fact it seems to
repeat the same check twice, as in the worst case of the incomming message being
TIPC_LOW_IMPORTANCE, its just going to check that the global limit is exactly
OVERLOAD_LIMIT_BASE/2 again.

Neil
