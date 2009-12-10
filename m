From: "Kumar Gopalpet-B05799" <B05799@freescale.com>
Subject: RE: [RFC] gianfar: Fix stats support
Date: Thu, 10 Dec 2009 13:13:02 +0530
Message-ID: <9F4C7D19E8361D4C94921B95BE08B81BA08AE5@zin33exm22.fsl.freescale.net>
References: <1260423764-21210-1-git-send-email-Sandeep.Kumar@freescale.com> <4B209173.7030304@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <avorontsov@ru.mvista.com>,
	<davem@davemloft.net>
To: "Eric Dumazet" <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:43874 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760661AbZLJHmT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Dec 2009 02:42:19 -0500
Received: from az33smr01.freescale.net (az33smr01.freescale.net [10.64.34.199])
	by az33egw02.freescale.net (8.14.3/az33egw02) with ESMTP id nBA7gPXh007757
	for <netdev@vger.kernel.org>; Thu, 10 Dec 2009 00:42:25 -0700 (MST)
Received: from zin33exm22.fsl.freescale.net (zin33exm22.ap.freescale.net [10.232.192.20])
	by az33smr01.freescale.net (8.13.1/8.13.0) with ESMTP id nBA7kZOj001326
	for <netdev@vger.kernel.org>; Thu, 10 Dec 2009 01:46:36 -0600 (CST)
Content-class: urn:content-classes:message
In-Reply-To: <4B209173.7030304@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 
>Fine by me, but if this patch is for linux-2.6.33, you can use 
>dev_txq_stats_fold() helper in your gfar_get_stats()
>
>dev_txq_stats_fold(dev, &dev->stats);
>return &dev->stats;
>

Eric, the problem in using dev_txq_stats_fold() will be that
txq->tx_dropped will not be updated. tx_dropped counter is updated on a
device level in the gfar_error( ) interrupt context (here we do not know
the txq index).
So, if we use dev_txq_stats_fold(), we will incorrectly give the
tx_dropped stats.

--

Thanks
Sandeep
