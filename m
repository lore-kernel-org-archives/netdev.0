From: Karl Beldan <karl.beldan@gmail.com>
Subject: Re: [PATCH 0/1] mv643xx_eth: Disable TSO by default
Date: Tue, 4 Nov 2014 15:20:20 +0100
Message-ID: <20141104142020.GA6728@magnum.frso.rivierawaves.com>
References: <1414855820-15094-1-git-send-email-ezequiel.garcia@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Tawfik Bayouk <tawfik@marvell.com>,
	Lior Amsalem <alior@marvell.com>,
	Nadav Haklai <nadavh@marvell.com>
To: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f175.google.com ([209.85.212.175]:40014 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753541AbaKDOU2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Nov 2014 09:20:28 -0500
Received: by mail-wi0-f175.google.com with SMTP id ex7so9554340wid.8
        for <netdev@vger.kernel.org>; Tue, 04 Nov 2014 06:20:27 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1414855820-15094-1-git-send-email-ezequiel.garcia@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Nov 01, 2014 at 12:30:19PM -0300, Ezequiel Garcia wrote:
> Several users ([1], [2]) have been reporting data corruption with TSO on
> Kirkwood platforms (i.e. using the mv643xx_eth driver).
> 
> Until we manage to find what's causing this, this simple patch will make
> the TSO path disabled by default. This patch should be queued for stable,
> fixing the TSO feature introduced in v3.16.
> 
> The corruption itself is very easy to reproduce: checking md5sum on a mounted
> NFS directory gives a different result each time. Same tests using the mvneta
> driver (Armada 370/38x/XP SoC) pass with no issues.
> 
> Frankly, I'm a bit puzzled about this, and so any ideas or debugging hints
> are well received.
> 

Hi,

Can you try this :

@@ -1067,7 +1082,8 @@ static int txq_reclaim(struct tx_queue *txq, int budget, int force)
 		txq->tx_desc_count--;
 
 		skb = NULL;
-		if (cmd_sts & TX_LAST_DESC)
+		if ((cmd_sts & (TX_LAST_DESC | TX_ENABLE_INTERRUPT)) ==
+			       (TX_LAST_DESC | TX_ENABLE_INTERRUPT))
 			skb = __skb_dequeue(&txq->tx_skb);
 
 		if (cmd_sts & ERROR_SUMMARY) {

-- 
Karl
