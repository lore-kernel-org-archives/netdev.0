From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Update pptp handling to avoid null pointer deref.
Date: Sun, 01 Jan 2017 23:07:53 -0500 (EST)
Message-ID: <20170101.230753.2076894379858224939.davem@davemloft.net>
References: <20170101231936.5905-1-ian.kumlien@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: ian.kumlien@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51058 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750707AbdABEH5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 1 Jan 2017 23:07:57 -0500
In-Reply-To: <20170101231936.5905-1-ian.kumlien@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ian Kumlien <ian.kumlien@gmail.com>
Date: Mon,  2 Jan 2017 00:19:36 +0100

> __skb_flow_dissect can be called with a skb or a data packet, either
> can be NULL. All calls seems to have been moved to __skb_header_pointer
> except the pptp handling which is still calling skb_header_pointer.
> 
> skb_header_pointer will use skb->data and thus:
 ...
> ---
> 
> Signed-off-by: Ian Kumlien <ian.kumlien@gmail.com>

You need to fix some parts of your submission.

Do not put the signoff after the "---", git will remove all text
after that "---" from the commit message.

You must include a proper "Fixes: " tag which indicates which change
introduced this regression.  This is critical for analyzing your fix
and also for figuring out which -stable releases your fix should be
backported to.

In this case the guilty commit is ab10dccb1160 ("rps: Inspect PPTP
encapsulated by GRE to get flow hash")
