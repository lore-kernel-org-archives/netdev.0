From: "pradeep singh" <pradeep.rautela@gmail.com>
Subject: Re: [PATCH v2.6.22-rc5] cxgb2: handle possible NULL pointer dereferencing, take 2
Date: Thu, 21 Jun 2007 18:48:30 +0530
Message-ID: <a901b49a0706210618q7c22cbe0jd6f7e052a8e05a97@mail.gmail.com>
References: <a901b49a0706210553r58ea8743gc565fcca1a87b58f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	jgarzik@pobox.com
To: trivial@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.183]:24351 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755180AbXFUNSb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jun 2007 09:18:31 -0400
Received: by wa-out-1112.google.com with SMTP id v27so313805wah
        for <netdev@vger.kernel.org>; Thu, 21 Jun 2007 06:18:30 -0700 (PDT)
In-Reply-To: <a901b49a0706210553r58ea8743gc565fcca1a87b58f@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,
My mistake.
Resending after reformatting the patch by hand.
Looks like gmail messes the plain text patches.

Thanks

Signed-off-by: Pradeep Singh <pradeep.rautela@gmail.com>
---
 drivers/net/chelsio/cxgb2.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/drivers/net/chelsio/cxgb2.c b/drivers/net/chelsio/cxgb2.c
index 231ce43..006c634 100644
--- a/drivers/net/chelsio/cxgb2.c
+++ b/drivers/net/chelsio/cxgb2.c
@@ -1022,6 +1022,11 @@ static int __devinit init_one(struct pci_dev *pdev,
       mmio_start = pci_resource_start(pdev, 0);
       mmio_len = pci_resource_len(pdev, 0);
       bi = t1_get_board_info(ent->driver_data);
+
+       if (!bi) {
+                CH_ERR("%s: Board info array index out of
range\n",pci_name(pdev));
+                goto out_disable_pdev;
+        }

       for (i = 0; i < bi->port_number; ++i) {
               struct net_device *netdev;

Thanks

--
On 6/21/07, pradeep singh <pradeep.rautela@gmail.com> wrote:
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
>  drivers/net/chelsio/cxgb2.c |    5 +++++
>  1 files changed, 5 insertions(+), 0 deletions(-)
>
> diff --git a/drivers/net/chelsio/cxgb2.c b/drivers/net/chelsio/cxgb2.c
> index 231ce43..006c634 100644
> --- a/drivers/net/chelsio/cxgb2.c
> +++ b/drivers/net/chelsio/cxgb2.c
> @@ -1022,6 +1022,11 @@ static int __devinit init_one(struct pci_dev *pdev,
>         mmio_start = pci_resource_start(pdev, 0);
>         mmio_len = pci_resource_len(pdev, 0);
>         bi = t1_get_board_info(ent->driver_data);
> +
> +       if (!bi) {
> +                CH_ERR("%s: Board info array index out of
> range\n",pci_name(pdev));
> +                goto out_disable_pdev;
> +        }
>
>         for (i = 0; i < bi->port_number; ++i) {
>                 struct net_device *netdev;
> --
> 1.4.4.2
>
> --
> Pradeep
>


-- 
Pradeep
