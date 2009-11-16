From: "Vladislav Zolotarov" <vladz@broadcom.com>
Subject: RE: [net-next] bnx2x: Handle Rx and Tx together in NAPI
Date: Mon, 16 Nov 2009 06:47:03 -0800
Message-ID: <8628FE4E7912BF47A96AE7DD7BAC0AADCB2D07B395@SJEXCHCCR02.corp.ad.broadcom.com>
References: <1258365669.8392.3.camel@lb-tlvb-vladz.il.broadcom.com>
 <20091116.022012.81633492.davem@davemloft.net>
 <8628FE4E7912BF47A96AE7DD7BAC0AADCB2D07B367@SJEXCHCCR02.corp.ad.broadcom.com>
 <20091116.032400.204096446.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3612 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752255AbZKPOrI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2009 09:47:08 -0500
In-Reply-To: <20091116.032400.204096446.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > There is another decision to make: what to do when Rx hasn't
> > consumed the whole budget and there is still Tx work to do. I think
> > that in this case we need to return "budget", so that we pushed to
> > the end on the local NAPI's list, "consuming" some global Rx budget
> > of the local NAPI. Another option is to return the number of Rx
> > packets handled and make this NAPI be called at once. My decision is
> > based on the fact that there were scenarios when net_tx_action and
> > net_rx_action were running on different CPUs in UDP Tx test and were
> > feeding each other. In this case if I implemented the later option I
> > would prevent other local NAPIs to run.
> 
> I think you should always process all of the pending TX work first,
> then do RX work and base your budget and rescheduling decisions
> purely on RX work.

Ok. I'm sending u a new patch.
