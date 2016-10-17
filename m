From: Jakub Kicinski <kubakici@wp.pl>
Subject: Re: [PATCH net-next 03/15] ethernet/intel: use core min/max MTU
 checking
Date: Mon, 17 Oct 2016 21:20:57 +0100
Message-ID: <20161017212057.42d4e91f@jkicinski-Precision-T1700>
References: <20161017195417.48259-1-jarod@redhat.com>
        <20161017195417.48259-4-jarod@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: Jarod Wilson <jarod@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.wp.pl ([212.77.101.10]:12183 "EHLO mx3.wp.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1758851AbcJQUVC (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 17 Oct 2016 16:21:02 -0400
In-Reply-To: <20161017195417.48259-4-jarod@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Looks better, unfortunately, I can't test since net-next also seem to
make nfs implode on my setup.

On Mon, 17 Oct 2016 15:54:05 -0400, Jarod Wilson wrote:
> @@ -7187,6 +7180,11 @@ static int e1000_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
>  		netdev->vlan_features |= NETIF_F_HIGHDMA;
>  	}
>  
> +	/* MTU range: 68 - max_hw_frame_size */
> +	netdev->min_mtu = ETH_MIN_MTU;

Nitpick: we probably don't have to reinit min_mtu if it's 68.
