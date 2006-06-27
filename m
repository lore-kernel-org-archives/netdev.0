From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 02/21] e1000: rework driver hardware reset locking
Date: Mon, 26 Jun 2006 21:42:04 -0400
Message-ID: <44A08CEC.1080108@pobox.com>
References: <20060622051815.25497.89192.stgit@gitlost.site> <20060622052009.25497.46358.stgit@gitlost.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:12500 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1030589AbWF0BmH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jun 2006 21:42:07 -0400
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
In-Reply-To: <20060622052009.25497.46358.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kok, Auke wrote:
> @@ -631,6 +627,9 @@ e1000_set_ringparam(struct net_device *n
>  	tx_ring_size = sizeof(struct e1000_tx_ring) * adapter->num_tx_queues;
>  	rx_ring_size = sizeof(struct e1000_rx_ring) * adapter->num_rx_queues;
>  
> +	while (test_and_set_bit(__E1000_RESETTING, &adapter->flags))
> +		msleep(1);

This is a bit worrying, but no outright objection.  We don't want to see 
these accumulate.

