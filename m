From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/5] dccp: Deprecate old setsockopt framework
Date: Sun, 16 Nov 2008 22:53:10 -0800 (PST)
Message-ID: <20081116.225310.261827389.davem@davemloft.net>
References: <1226751079-15019-1-git-send-email-gerrit@erg.abdn.ac.uk>
	<1226751079-15019-2-git-send-email-gerrit@erg.abdn.ac.uk>
	<1226751079-15019-3-git-send-email-gerrit@erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org
To: gerrit@erg.abdn.ac.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48334
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751216AbYKQGxK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Nov 2008 01:53:10 -0500
In-Reply-To: <1226751079-15019-3-git-send-email-gerrit@erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat, 15 Nov 2008 13:11:16 +0100

> The previous setsockopt interface, which passed socket options via struct
> dccp_so_feat, is complicated/difficult to use. Continuing to support it leads to
> ugly code since the old approach did not distinguish between NN and SP values.
> 
> This patch removes the old setsockopt interface and replaces it with two new
> functions to register NN/SP values for feature negotiation. 
> These are essentially wrappers around the internal __feat_register functions,
> with checking added to avoid
> 
>  * wrong usage (type);
>  * changing values while the connection is in progress.
> 
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Applied, I'll trust your judgment that we can get away with this...

But you have to understand that this is something you should think
about never doing again.  User interfaces are never "oops sorry, we
misdesigned that, we'll just take it away and emit some warning,
fix your app"  Once it's out there, you gotta support it forever.

