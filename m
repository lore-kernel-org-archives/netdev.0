From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: RE: [PATCH] [NET]: Fix Ooops of napi net_rx_action.
Date: Tue, 11 Dec 2007 15:12:10 -0800
Message-ID: <36D9DB17C6DE9E40B059440DB8D95F5203F82FC3@orsmsx418.amr.corp.intel.com>
References: <001801c83bd6$2001d410$9c94fea9@jason> <20071211.023218.31965443.davem@davemloft.net> <b25c3fa70712110457g2bf04c6flc387f2b9cb51cf3b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<herbert@gondor.apana.org.au>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>
To: "Joonwoo Park" <joonwpark81@gmail.com>,
	"David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:46058 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750772AbXLKXWA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2007 18:22:00 -0500
Content-class: urn:content-classes:message
In-Reply-To: <b25c3fa70712110457g2bf04c6flc387f2b9cb51cf3b@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Joonwoo Park wrote:
>     /* If no Tx and not enough Rx work done, exit the polling mode */
>     if ((!tx_cleaned && (work_done == 0)) ||
>        !netif_running(poll_dev)) {
> quit_polling:
>         if (likely(adapter->itr_setting & 3))
>             e1000_set_itr(adapter);
>         netif_rx_complete(poll_dev, napi);
>         e1000_irq_enable(adapter);

all drivers using NAPI in 2.6.24+ (NNAPI??) must return zero here, after
calling netif_rx_complete.  netif_rx_complete plus work_done != 0 causes
a bug.

>     }
> 
>     return work_done;
> }
> 
