From: "Rose, Gregory V" <gregory.v.rose@intel.com>
Subject: RE: [RFC PATCH v2 04/12] ixgbevf: Driver main and ethool interface
 module and main header
Date: Mon, 21 Dec 2009 10:18:22 -0800
Message-ID: <43F901BD926A4E43B106BF17856F07559A2588F2@orsmsx508.amr.corp.intel.com>
References: <20091218225043.10698.58897.stgit@localhost.localdomain>
 <20091218225158.10698.67726.stgit@localhost.localdomain>
 <20091221075951.GD21782@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>
To: Simon Horman <horms@verge.net.au>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:8859 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751244AbZLUSSZ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Dec 2009 13:18:25 -0500
In-Reply-To: <20091221075951.GD21782@verge.net.au>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-----Original Message-----
From: Simon Horman [mailto:horms@verge.net.au] 
Sent: Monday, December 21, 2009 12:00 AM
To: Kirsher, Jeffrey T
Cc: netdev@vger.kernel.org; gospo@redhat.com; Rose, Gregory V
Subject: Re: [RFC PATCH v2 04/12] ixgbevf: Driver main and ethool interface module and main header

> +
> +	if (new_rx_count != adapter->rx_ring_count) {
> +		memcpy(rx_ring, adapter->rx_ring,
> +		       adapter->num_rx_queues * sizeof(struct ixgbevf_ring));
> +		for (i = 0; i < adapter->num_rx_queues; i++) {
> +			rx_ring[i].count = new_rx_count;
> +			err = ixgbevf_setup_rx_resources(adapter,
> +							 &rx_ring[i]);
> +			if (err) {
> +				while (i) {
> +					i--;
> +					ixgbevf_free_rx_resources(adapter,
> +								  &rx_ring[i]);
> +				}
> +				goto err_setup;

				Are some calls to ixgbevf_free_tx_resources()
				needed here? Perhaps the ones for
				on rx_ring failure could be moved down
				to an err_tx_clear or similar?
				(sorry for the shoddy name)

Let me have a look at it and see what I can (or should) do with it.

> +			}
> +			rx_ring[i].v_idx = adapter->rx_ring[i].v_idx;
> +		}
> +		need_update = true;
> +	}
> +
> +	/* if rings need to be updated, here's the place to do it in one shot */
> +	if (need_update) {
> +		if (netif_running(netdev))
> +			ixgbevf_down(adapter);
> +
> +		/* tx */
> +		if (new_tx_count != adapter->tx_ring_count) {
> +			kfree(adapter->tx_ring);
> +			adapter->tx_ring = tx_ring;
> +			tx_ring = NULL;
> +			adapter->tx_ring_count = new_tx_count;
> +		}
> +
> +		/* rx */
> +		if (new_rx_count != adapter->rx_ring_count) {
> +			kfree(adapter->rx_ring);
> +			adapter->rx_ring = rx_ring;
> +			rx_ring = NULL;
> +			adapter->rx_ring_count = new_rx_count;
> +		}
> +	}

	Can tx_ring and rx_ring leak here?

Maybe?  Let me look at it a bit closer and see.

I've also looked at your comments to 2/12 and will see what I can do to incorporate your suggestions there.  I appreciate the close review of the code.

- Greg

