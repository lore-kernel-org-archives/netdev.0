From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] sunvnet: Packet processing in
 non-interrupt context.
Date: Thu, 02 Oct 2014 13:43:46 -0700 (PDT)
Message-ID: <20141002.134346.2291749763304558513.davem@davemloft.net>
References: <20141001202315.GN17706@oracle.com>
	<20141001.162529.2246298941833907545.davem@davemloft.net>
	<20141002201203.GA6001@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: raghuram.kothakota@oracle.com, netdev@vger.kernel.org
To: sowmini.varadhan@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47514 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751723AbaJBUlp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Oct 2014 16:41:45 -0400
In-Reply-To: <20141002201203.GA6001@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Date: Thu, 2 Oct 2014 16:12:03 -0400

> The patch is attached to the end of this email.

There are an explosion of simplifications and optimizations
possilbe once you've done a NAPI conversion, which I haven't
seen you perform here in this patch.

For example, you can now move everything into software IRQ context,
just disable the VIO interrupt and unconditionally go into NAPI
context from the VIO event.

No more irqsave/irqrestore.

Then the TX path even can run mostly lockless, it just needs
to hold the VIO lock for a minute period of time.  The caller
holds the xmit_lock of the network device to prevent re-entry
into the ->ndo_start_xmit() path.

Really, what you've done here as a NAPI conversion is just the
beginning.
