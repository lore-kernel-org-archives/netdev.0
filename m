From: "Rose, Gregory V" <gregory.v.rose@intel.com>
Subject: RE: [PATCH 23/49] drivers/net/igbvf: Use vzalloc
Date: Fri, 5 Nov 2010 04:58:46 -0700
Message-ID: <43F901BD926A4E43B106BF17856F07550124A9DFFE@orsmsx508.amr.corp.intel.com>
References: <cover.1288925424.git.joe@perches.com>
 <9f8b974fadf646f9227bd1d5fe8e448081ec9b2b.1288925424.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Wyborny, Carolyn" <carolyn.wyborny@intel.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"Duyck, Alexander H" <alexander.h.duyck@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Joe Perches <joe@perches.com>, Jiri Kosina <trivial@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:20814 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751758Ab0KEL6t convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Nov 2010 07:58:49 -0400
In-Reply-To: <9f8b974fadf646f9227bd1d5fe8e448081ec9b2b.1288925424.git.joe@perches.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Joe Perches [mailto:joe@perches.com]
> Sent: Thursday, November 04, 2010 8:08 PM
> To: Jiri Kosina
> Cc: Kirsher, Jeffrey T; Brandeburg, Jesse; Allan, Bruce W; Wyborny,
> Carolyn; Skidmore, Donald C; Rose, Gregory V; Waskiewicz Jr, Peter P;
> Duyck, Alexander H; Ronciak, John; e1000-devel@lists.sourceforge.net;
> netdev@vger.kernel.org; linux-kernel@vger.kernel.org
> Subject: [PATCH 23/49] drivers/net/igbvf: Use vzalloc
> 
> Signed-off-by: Joe Perches <joe@perches.com>
> ---
>  drivers/net/igbvf/netdev.c |    6 ++----
>  1 files changed, 2 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/net/igbvf/netdev.c b/drivers/net/igbvf/netdev.c
> index 28af019..08e7459 100644
> --- a/drivers/net/igbvf/netdev.c
> +++ b/drivers/net/igbvf/netdev.c
> @@ -429,10 +429,9 @@ int igbvf_setup_tx_resources(struct igbvf_adapter
> *adapter,
>  	int size;
> 
>  	size = sizeof(struct igbvf_buffer) * tx_ring->count;
> -	tx_ring->buffer_info = vmalloc(size);
> +	tx_ring->buffer_info = vzalloc(size);
>  	if (!tx_ring->buffer_info)
>  		goto err;
> -	memset(tx_ring->buffer_info, 0, size);
> 
>  	/* round up to nearest 4K */
>  	tx_ring->size = tx_ring->count * sizeof(union e1000_adv_tx_desc);
> @@ -469,10 +468,9 @@ int igbvf_setup_rx_resources(struct igbvf_adapter
> *adapter,
>  	int size, desc_len;
> 
>  	size = sizeof(struct igbvf_buffer) * rx_ring->count;
> -	rx_ring->buffer_info = vmalloc(size);
> +	rx_ring->buffer_info = vzalloc(size);
>  	if (!rx_ring->buffer_info)
>  		goto err;
> -	memset(rx_ring->buffer_info, 0, size);
> 
>  	desc_len = sizeof(union e1000_adv_rx_desc);
> 
> --
> 1.7.3.1.g432b3.dirty

Acked By: Greg Rose <Gregory.v.rose@intel.com>

