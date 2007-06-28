From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2/3] NET: [CORE] Stack changes to add multiqueue hardware
 support API
Date: Thu, 28 Jun 2007 21:20:04 +0200
Message-ID: <468409E4.7000603@trash.net>
References: <D5C1322C3E673F459512FB59E0DDC329031F061E@orsmsx414.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, jeff@garzik.org,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>, hadi@cyberus.ca
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:57761 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756516AbXF1TVC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jun 2007 15:21:02 -0400
In-Reply-To: <D5C1322C3E673F459512FB59E0DDC329031F061E@orsmsx414.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Waskiewicz Jr, Peter P wrote:
>>Waskiewicz Jr, Peter P wrote:
>>
>>Yes, I noticed that now. Doesn't seem right though as long as
>>queueing while queue is stopped is treated as a bug by the
>>drivers.
>>
>>But I vaguely recall seeing a discussion about this, I'll check
>>the archives.
> 
> 
> The basic gist is before the dequeue is done, the qdisc is locked by the
> qdisc is running bit, so another CPU cannot get in there.  So if the
> queue isn't stopped when a dequeue is done, that same queue should not
> be stopped when hard_start_xmit() is called.  The only thing I could
> think of that could happen is some out-of-band cleanup routine in the
> driver where the tx_ring lock is held, and the skb is bounced back,
> where the driver returns NETIF_TX_BUSY, and you requeue.  This is an
> extreme corner case, so the check could be removed.


Yes, but there are users that don't go through qdiscs, like netpoll,
Having them check the QDISC_RUNNING bit seems ugly.
