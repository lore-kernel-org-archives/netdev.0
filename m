From: "Kumar Gopalpet-B05799" <B05799@freescale.com>
Subject: RE: [net-next] bnx2x: Handle Rx and Tx together in NAPI
Date: Mon, 16 Nov 2009 16:02:04 +0530
Message-ID: <9F4C7D19E8361D4C94921B95BE08B81B950BEF@zin33exm22.fsl.freescale.net>
References: <1258365669.8392.3.camel@lb-tlvb-vladz.il.broadcom.com> <20091116.022012.81633492.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <eilong@broadcom.com>
To: "David Miller" <davem@davemloft.net>, <vladz@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:52877 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751134AbZKPKcE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2009 05:32:04 -0500
Received: from az33smr02.freescale.net (az33smr02.freescale.net [10.64.34.200])
	by az33egw02.freescale.net (8.14.3/az33egw02) with ESMTP id nAGAW8QZ024947
	for <netdev@vger.kernel.org>; Mon, 16 Nov 2009 03:32:08 -0700 (MST)
Received: from zin33exm22.fsl.freescale.net (zin33exm22.ap.freescale.net [10.232.192.20])
	by az33smr02.freescale.net (8.13.1/8.13.0) with ESMTP id nAGAW7vI011545
	for <netdev@vger.kernel.org>; Mon, 16 Nov 2009 04:32:08 -0600 (CST)
Content-class: urn:content-classes:message
In-Reply-To: <20091116.022012.81633492.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 

>From: "Vladislav Zolotarov" <vladz@broadcom.com>
>Date: Mon, 16 Nov 2009 12:01:09 +0200
>
>>   - Limit Tx work done in one iteration by the same number 
>of packets 
>> as Rx in order to ensure both fair work load balancing relatively to 
>> other devices scheduled for NAPI on the local CPU and sane Tx/Rx skb 
>> resource management from single QP perspective.
>
>You should not do this.

Can we actually introduce NAPI mechanism for cleaning TX ring ??
 
>RX is several orders of magnitude more work than TX is.  TX 
>therefore should not be charged against the NAPI polling quota.
>
>Don't try to be different from other drivers unless you have 
>detailed performance numbers from various situations (local 
>TCP flows _and_
>routing) to justify it. :-)
>
I tried (I am talking about gianfar driver) to introduce napi for
cleaning tx ring (similar to rx napi mechanism ) and found that it
actually improves performance for bi-directioanl flow on an SMP system
(performance is abt 1.6 times). 
If introducing napi mechansim for tx is logical then I will send out an
RFC patch
>All NAPI drivers ignore TX work when considering NAPI polling 
>quotas and you should too :-)
>--


--

Thanks
Sandeep
