From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 1/5] ucc_geth: Reduce IRQ off in xmit path
Date: Thu, 20 Sep 2012 00:34:16 +0200
Message-ID: <20120919223416.GA16087@electric-eye.fr.zoreil.com>
References: <1347987385-19071-1-git-send-email-Joakim.Tjernlund@transmode.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:53834 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752436Ab2ISWw3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2012 18:52:29 -0400
Content-Disposition: inline
In-Reply-To: <1347987385-19071-1-git-send-email-Joakim.Tjernlund@transmode.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Joakim Tjernlund <Joakim.Tjernlund@transmode.se> :
> Currently ucc_geth_start_xmit wraps IRQ off for the
> whole body just to be safe.
> Reduce the IRQ off period to a minimum.

It opens a window in ucc_geth_start_xmit where the skb slot in
ugeth->tx_skbuff[txQ] is set and T_RA has not been written into
the descriptor status. Consider a racing poll : the !skb test in
ucc_geth_tx may not work as expected.

-- 
Ueimor
