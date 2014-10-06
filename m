From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH net-next 0/2] sunvnet: Packet processing in non-interrupt
 context.
Date: Mon, 6 Oct 2014 15:31:11 -0400
Message-ID: <20141006193111.GE24721@oracle.com>
References: <20141003144024.GA12448@oracle.com>
 <20141003.120802.1213573830649867131.davem@davemloft.net>
 <20141006160418.GA3604@oracle.com>
 <20141006.152526.965519223260573233.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: raghuram.kothakota@oracle.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:30340 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752082AbaJFTbT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2014 15:31:19 -0400
Content-Disposition: inline
In-Reply-To: <20141006.152526.965519223260573233.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (10/06/14 15:25), David Miller wrote:
> 
> > But we still need to hold the vio lock around the ldc_write 
> > (and also around dring write) in vnet_start_xmit, right?
> 
> You might be able to avoid it, you're fully serialized by the TX queue
> lock.

yes, I was just noticing that. The only place where I believe I need
to hold the vio spin-lock is to sync with the dr->cons checks
(the "should I send a start_cons LDC message?" check in vnet_start_xmit()
vs the vnet_ack() updates).

But isn't it better in general to declare NETIF_F_LLTX and have finer lock
granularity in the driver?

--Sowmini
