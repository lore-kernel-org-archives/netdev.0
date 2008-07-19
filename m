From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 10/13]: net: Implement simple sw TX hashing.
Date: Sat, 19 Jul 2008 00:26:56 -0700 (PDT)
Message-ID: <20080719.002656.186841207.davem@davemloft.net>
References: <20080710.035713.204601759.davem@davemloft.net>
	<20080717091641.18684218@extreme>
	<487F7187.9060909@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37851
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751212AbYGSH05 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Jul 2008 03:26:57 -0400
In-Reply-To: <487F7187.9060909@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Thu, 17 Jul 2008 18:21:27 +0200

> Actually I think we could just make the number of tx queues of
> virtual devices match the lower device and use the unencapsulated
> packets for queue selection.
> 
> Of course that would require not to perform queue selection
> again on the real device. For VLANs, macvlan etc. that don't
> do any locking internally that would probably make sense.

Agreed.

> Not sure about PPPoE.

PPPOE just sends down to dev_queue_xmit() with the new device
after encapsulating, and the network header is set correctly.
Therefore this case can just be left as-is.
