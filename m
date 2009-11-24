From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH] igb: fix misinterpreted return value of pci_enable_msix
Date: Tue, 24 Nov 2009 11:40:49 +0100
Message-ID: <20091124104049.GB21600@Chamillionaire.breakpoint.cc>
References: <4B0BB5FE.2000907@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>,
	Andy Gospodarek <gospo@redhat.com>,
	alexander.h.duyck@intel.com, davem@davemloft.net
To: Stefan Assmann <sassmann@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:33950 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932687AbZKXKko (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Nov 2009 05:40:44 -0500
Content-Disposition: inline
In-Reply-To: <4B0BB5FE.2000907@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stefan Assmann <sassmann@redhat.com> wrote:
> From: Stefan Assmann <sassmann@redhat.com>
> 
> In the igb driver a return value of 0 of function pci_enable_msix is
> interpreted as an error case. The correct behaviour is to check < 0 for error
> values.
> 
> Signed-off-by: Stefan Assmann <sassmann@redhat.com>
> ---
>  drivers/net/igb/igb_main.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
> index bb1a6ee..745481d 100644
> --- a/drivers/net/igb/igb_main.c
> +++ b/drivers/net/igb/igb_main.c
> @@ -694,7 +694,7 @@ static void igb_set_interrupt_capability(struct igb_adapter *adapter)
>  	err = pci_enable_msix(adapter->pdev,
>  			      adapter->msix_entries,
>  			      numvecs);
> -	if (err == 0)
> +	if (err < 0)
>  		goto out;
>

The existing code looks correct to me:

      if (err == 0)
            goto out;

      igb_reset_interrupt_capability(adapter);

      /* If we can't do MSI-X, try MSI * */
msi_only:


so the "goto out" appears to be the "success" case.
