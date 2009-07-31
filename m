From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: Re: [net-next-2.6 PATCH 6/9] ixgb: return PCI_ERS_RESULT_DISCONNECT
 on permanent failure
Date: Fri, 31 Jul 2009 12:44:03 -0700 (Pacific Daylight Time)
Message-ID: <Pine.WNT.4.64.0907311236400.9560@ppwaskie-MOBL2.amr.corp.intel.com>
References: <20090731191254.5470.99642.send-patch@aqua>
 <20090731191340.5470.79342.send-patch@aqua>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: Dean Nelson <dnelson@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:1919 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751376AbZGaToE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Jul 2009 15:44:04 -0400
In-Reply-To: <20090731191340.5470.79342.send-patch@aqua>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 31 Jul 2009, Dean Nelson wrote:

> PCI drivers that implement the struct pci_error_handlers' error_detected
> callback should return PCI_ERS_RESULT_DISCONNECT if the state passed in is
> pci_channel_io_perm_failure. This patch fixes the issue for ixgb.
> 
> Signed-off-by: Dean Nelson <dnelson@redhat.com>
> 
> ---
> 
> This patch has not been tested, since I don't have the hardware to test it.
> It is based on a few recent patches. See the following commits:
> 
> http://git.kernel.org/linus/c93b5a76d58656158d195a7df507ebc660010969
> http://git.kernel.org/linus/eab633021c26025b34f36f79f0311d3d99f40ceb
> http://git.kernel.org/linus/ef681ce1e8b3e63317cd724c200b2fd39286c005
> http://git.kernel.org/linus/59ed6eecff4aa00c5c5d18ffd180acac108d596e
> http://git.kernel.org/linus/3044b8d1ff8c05237652a692fb572a34e4d70146
> 
>  drivers/net/ixgb/ixgb_main.c |    5 +++++
>  1 files changed, 5 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
> index eb917f1..fad08ce 100644
> --- a/drivers/net/ixgb/ixgb_main.c
> +++ b/drivers/net/ixgb/ixgb_main.c
> @@ -2227,6 +2227,11 @@ static pci_ers_result_t ixgb_io_error_detected(struct pci_dev *pdev,
>  	struct net_device *netdev = pci_get_drvdata(pdev);
>  	struct ixgb_adapter *adapter = netdev_priv(netdev);
>  
> +	netif_device_detach(netdev);
> +
> +	if (state == pci_channel_io_perm_failure)
> +		return PCI_ERS_RESULT_DISCONNECT;
> +
>  	if (netif_running(netdev))
>  		ixgb_down(adapter, true);

Seems reasonable, especially since the same logic works fine on our other 
drivers.  The hardware for this driver is somewhat difficult to get our 
hands on, but we'll definately give this a spot test once we can locate 
one of these NICs.

Cheers,
-PJ Waskiewicz
