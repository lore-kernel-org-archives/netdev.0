From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH v3 6/6] net: sh_eth: use NAPI
Date: Tue, 15 May 2012 15:43:07 +0200
Message-ID: <20120515134307.GA31377@electric-eye.fr.zoreil.com>
References: <4FB0AA7C.1000603@renesas.com> <20120514.185034.399229364191924851.davem@davemloft.net> <4FB1DFF0.4040709@renesas.com> <20120515.010753.2012331320750491448.davem@davemloft.net> <4FB225F1.20407@renesas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-sh@vger.kernel.org
To: "Shimoda, Yoshihiro" <yoshihiro.shimoda.uh@renesas.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:46604 "EHLO violet"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1758898Ab2EONuO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 May 2012 09:50:14 -0400
Content-Disposition: inline
In-Reply-To: <4FB225F1.20407@renesas.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Shimoda, Yoshihiro <yoshihiro.shimoda.uh@renesas.com> :
[...]
> I will modify the code as the following. Is it correct?

No.

Please take a look at tg3, especially the ...mb() calls and rework the
queue disabling part in the xmit handler. Btw sh_eth_txfree has no
business being called from the xmit and poll handlers at the same time.

There is no memory barrier in the xmit handler. It it not clear if the
poll thread always sees tx ring status and cur_tx updates in the same
order or not. If not, the driver may unmap before the device actually
accesses skb buffer.

-- 
Ueimor
