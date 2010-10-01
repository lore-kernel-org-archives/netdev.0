From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] be2net: add multiple RX queue support
Date: Thu, 30 Sep 2010 17:39:57 -0700 (PDT)
Message-ID: <20100930.173957.55855786.davem@davemloft.net>
References: <20100929120113.GA16206@emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sathya.perla@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33364
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752632Ab0JAAjh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Sep 2010 20:39:37 -0400
In-Reply-To: <20100929120113.GA16206@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathya.perla@emulex.com>
Date: Wed, 29 Sep 2010 17:31:13 +0530

> @@ -78,6 +78,13 @@ static inline char *nic_name(struct pci_dev *pdev)
>  #define MCC_Q_LEN		128	/* total size not to exceed 8 pages */
>  #define MCC_CQ_LEN		256
>  
> +#ifdef CONFIG_PPC64			/* ppc platforms support only max of */
> +#define NUM_RSS_QS		2	/* 4 msix vectors per pci function   */
> +#else
> +#define NUM_RSS_QS		4	/* BE limit is 4 queues/port	     */
> +#endif

If the first hunk I see in a patch is something like this, it is
not a good sign.

This is something you need to discover dynamically, and the MSI-X
vector enable functions in the kernel allow you to do this just fine.

Look at what other drivers do, they have a specific number of vectora
they try to obtain using pci_enable_msix(), and if that fails they
decrease the vector count until they are able to succeed.
