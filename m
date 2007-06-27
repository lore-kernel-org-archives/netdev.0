From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH v2.6.22-rc5] cxgb2: handle possible NULL pointer dereferencing,
 take 2
Date: Wed, 27 Jun 2007 02:30:13 -0400
Message-ID: <468203F5.2020501@garzik.org>
References: <a901b49a0706210553r58ea8743gc565fcca1a87b58f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: trivial@kernel.org, netdev@vger.kernel.org
To: pradeep singh <pradeep.rautela@gmail.com>,
	akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:37811 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759304AbXF0GaT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Jun 2007 02:30:19 -0400
In-Reply-To: <a901b49a0706210553r58ea8743gc565fcca1a87b58f@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

pradeep singh wrote:
> Hi,
> This is second submission for a possible NULL dereference handling in
> the Chelsio's 10G driver.
> 
> Thanks to Jens Axboe for pointing out my mistake of ignoring
> subsequent dereferences in init_one routine.
> 
> Thanks
> 
> Signed-off-by: Pradeep Singh <pradeep.rautela@gmail.com>
> ---
> drivers/net/chelsio/cxgb2.c |    5 +++++
> 1 files changed, 5 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/chelsio/cxgb2.c b/drivers/net/chelsio/cxgb2.c
> index 231ce43..006c634 100644
> --- a/drivers/net/chelsio/cxgb2.c
> +++ b/drivers/net/chelsio/cxgb2.c
> @@ -1022,6 +1022,11 @@ static int __devinit init_one(struct pci_dev *pdev,
>     mmio_start = pci_resource_start(pdev, 0);
>     mmio_len = pci_resource_len(pdev, 0);
>     bi = t1_get_board_info(ent->driver_data);
> +   
> +    if (!bi) {
> +                CH_ERR("%s: Board info array index out of
> range\n",pci_name(pdev));
> +                goto out_disable_pdev;
> +        }

NAK.  It's impossible to hit this condition.

	Jeff


