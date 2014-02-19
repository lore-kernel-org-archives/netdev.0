From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] qeth: postpone freeing of qdio memory
Date: Wed, 19 Feb 2014 16:47:39 -0500 (EST)
Message-ID: <20140219.164739.1860650180590714358.davem@davemloft.net>
References: <20140219091451.GA17591@tuxmaker.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: blaschka@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47105 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751956AbaBSVrl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Feb 2014 16:47:41 -0500
In-Reply-To: <20140219091451.GA17591@tuxmaker.boeblingen.de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Frank Blaschka <blaschka@linux.vnet.ibm.com>
Date: Wed, 19 Feb 2014 10:14:51 +0100

> @@ -4919,6 +4919,7 @@ retry:
>  	if (rc)
>  		goto retriable;
>  	rc = qeth_qdio_clear_card(card, card->info.type != QETH_CARD_TYPE_IQD);
> +	qdio_free(CARD_DDEV(card));
>  retriable:
>  	if (rc == -ERESTARTSYS) {
>  		QETH_DBF_TEXT(SETUP, 2, "break1");

You do not want to do the qdio_free() if the qeth_qdio_clear_card() returns
an error value that causes a retry, and yes that can indeed happen.  The halt
paths return things like -ETIME etc.
