From: David Miller <davem@davemloft.net>
Subject: Re: [net] gianfar: Add FCS to rx buffer size (fix)
Date: Wed, 15 Oct 2014 16:54:21 -0400 (EDT)
Message-ID: <20141015.165421.2180002967619380071.davem@davemloft.net>
References: <1413389506-19172-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kotnes@cisco.com
To: claudiu.manoil@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54213 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752371AbaJOUyY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Oct 2014 16:54:24 -0400
In-Reply-To: <1413389506-19172-1-git-send-email-claudiu.manoil@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Claudiu Manoil <claudiu.manoil@freescale.com>
Date: Wed, 15 Oct 2014 19:11:46 +0300

> For each Rx frame the eTSEC writes its FCS (Frame Check Sequence)
> to the Rx buffer.
> 
> The eTSEC h/w manual states in the "Receive Buffer Descriptor Field
> Descriptions" table:
> "Data length is the number of octets written by the eTSEC into this BD's
> data buffer if L is cleared (the value is equal to MRBLR), or, if L is
> set, the length of the frame including *CRC*, FCB (if RCTRL[PRSDEP > 00),
> preamble (if MACCFG2[PreAmRxEn]=1), time stamp (if RCTRL[TS] = 1) and
> any padding (RCTRL[PAL])."
> 
> Though the FCS bytes are removed by the driver before passing the skb
> to the net stack, the Rx buffer size computation does not currently
> take into account the FCS bytes (4 bytes).
> Because the Rx buffer size is multiple of 512 bytes, leaving out the
> FCS is not a problem for the default MTU of 1500, as the Rx buffer size
> is 1536 in this case.  However, for custom MTUs, where the difference
> between the MTU size and the Rx buffer size is less, this can be a
> problem as the computed Rx buffer size won't be enough to accomodate
> the FCS for a received frame that is big enough (close to MTU size).
> In such case the received frame is considered to be incomplete (L flag
> not set in the RxBD status) and silently dropped.
> 
> Note that the driver does not currently support S/G on Rx, so it has to
> compute its Rx buffer size based on the MTU of the device.
> 
> Reported-by: Kristian Otnes <kotnes@cisco.com>
> Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>

Applied, thanks!
