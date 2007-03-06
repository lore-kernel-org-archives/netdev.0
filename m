From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH] [TCP]: Reworked recovery's TCPCB_LOST marking
 functions
Date: Tue, 06 Mar 2007 13:47:26 -0800 (PST)
Message-ID: <20070306.134726.39155177.davem@davemloft.net>
References: <Pine.LNX.4.64.0703061442440.3770@kivilampi-30.cs.helsinki.fi>
	<20070306194259.GK25760@galon.ev-en.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ilpo.jarvinen@helsinki.fi, netdev@vger.kernel.org
To: baruch@ev-en.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50792
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1030259AbXCFVr3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Mar 2007 16:47:29 -0500
In-Reply-To: <20070306194259.GK25760@galon.ev-en.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Baruch Even <baruch@ev-en.org>
Date: Tue, 6 Mar 2007 21:42:59 +0200

> * Ilpo J?rvinen <ilpo.jarvinen@helsinki.fi> [070306 14:52]:
> > +		newtp->highest_sack = treq->snt_isn + 1;
> 
> That's the only initialization that you have for highest_sack, I think
> that you should initialize it when a loss is detected to the start_seq
> of the first packet that wasn't acked.

He also sets it in tcp_sacktag_write_queue() like this:

+
+				if (after(TCP_SKB_CB(skb)->seq,
+				    tp->highest_sack))
+					tp->highest_sack = TCP_SKB_CB(skb)->seq;
