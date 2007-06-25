From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2.6.22-rc5] cxgb2: handle possible NULL pointer
 dereferencing, take 2
Date: Mon, 25 Jun 2007 15:34:50 -0700
Message-ID: <20070625153450.c5f535ca.akpm@linux-foundation.org>
References: <a901b49a0706210553r58ea8743gc565fcca1a87b58f@mail.gmail.com>
	<a901b49a0706210618q7c22cbe0jd6f7e052a8e05a97@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: trivial@kernel.org, netdev@vger.kernel.org, jgarzik@pobox.com
To: "pradeep singh" <pradeep.rautela@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:37190 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752570AbXFYWgF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2007 18:36:05 -0400
In-Reply-To: <a901b49a0706210618q7c22cbe0jd6f7e052a8e05a97@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 21 Jun 2007 18:48:30 +0530
"pradeep singh" <pradeep.rautela@gmail.com> wrote:

> diff --git a/drivers/net/chelsio/cxgb2.c b/drivers/net/chelsio/cxgb2.c
> index 231ce43..006c634 100644
> --- a/drivers/net/chelsio/cxgb2.c
> +++ b/drivers/net/chelsio/cxgb2.c
> @@ -1022,6 +1022,11 @@ static int __devinit init_one(struct pci_dev *pdev,
>        mmio_start = pci_resource_start(pdev, 0);
>        mmio_len = pci_resource_len(pdev, 0);
>        bi = t1_get_board_info(ent->driver_data);
> +
> +       if (!bi) {
> +                CH_ERR("%s: Board info array index out of range\n",pci_name(pdev));
> +                goto out_disable_pdev;
> +        }
> 
>        for (i = 0; i < bi->port_number; ++i) {
>                struct net_device *netdev;

The chelsio driver is assuming that pci_device_id.driver_data has been
initialised to the board index, but I am unable to locate anywhere where
that initialisation actually happens.  Is this a bug?

(Who maintains this driver now?)
