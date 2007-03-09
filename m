From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 2/2] e1000: Implement the new kernel API for multiqueue TX support.
Date: Fri, 9 Mar 2007 14:11:16 +0100
Message-ID: <20070309131116.GG521@postel.suug.ch>
References: <20070209000942.5155.78998.stgit@gitlost.site> <20070209000952.5155.96947.stgit@gitlost.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	"Garzik, Jeff" <jgarzik@pobox.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Peter Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:32857 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1767290AbXCINlx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Mar 2007 08:41:53 -0500
Content-Disposition: inline
In-Reply-To: <20070209000952.5155.96947.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Kok, Auke <auke-jan.h.kok@intel.com> 2007-02-08 16:09
> 
> From: Peter Waskiewicz Jr. <peter.p.waskiewicz.jr@intel.com>
> 
> Several newer e1000 chipsets support multiple RX and TX queues. Most
> commonly, 82571's and ESB2LAN support 2 rx and 2 rx queues.
> 
> Signed-off-by: Peter Waskiewicz Jr. <peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
> ---
> 
>  drivers/net/Kconfig               |   13 ++
>  drivers/net/e1000/e1000.h         |   23 +++
>  drivers/net/e1000/e1000_ethtool.c |   43 ++++++
>  drivers/net/e1000/e1000_main.c    |  269 +++++++++++++++++++++++++++++++------
>  4 files changed, 304 insertions(+), 44 deletions(-)
> 
> diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
> index ad92b6a..2d758ab 100644
> --- a/drivers/net/Kconfig
> +++ b/drivers/net/Kconfig
> @@ -1988,6 +1988,19 @@ config E1000_DISABLE_PACKET_SPLIT
>  
>  	  If in doubt, say N.
>  
> +config E1000_MQ
> +	bool "Enable Tx/Rx Multiqueue Support (EXPERIMENTAL)"
> +	depends on E1000 && NET_MULTI_QUEUE_DEVICE && EXPERIMENTAL

Would be better to just select NET_MULTI_QUEUE_DEVICE instead of
depending on it.
