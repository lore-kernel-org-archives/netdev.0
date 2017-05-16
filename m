From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [oss-drivers] [PATCH net-next 8/9] nfp: add a helper for
 wrapping descriptor index
Date: Tue, 16 May 2017 09:08:08 +0200
Message-ID: <20170516070806.GC11965@vergenet.net>
References: <20170516005523.26124-1-jakub.kicinski@netronome.com>
 <20170516005523.26124-9-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, oss-drivers@netronome.com
To: Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f175.google.com ([209.85.220.175]:35069 "EHLO
        mail-qk0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750950AbdEPHIK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 16 May 2017 03:08:10 -0400
Received: by mail-qk0-f175.google.com with SMTP id a72so118803678qkj.2
        for <netdev@vger.kernel.org>; Tue, 16 May 2017 00:08:10 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170516005523.26124-9-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 15, 2017 at 05:55:22PM -0700, Jakub Kicinski wrote:
> We have a number of places where we calculate the descriptor
> index based on a value which may have overflown.  Create a
> macro for masking with the ring size.
> 
> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
> ---
>  drivers/net/ethernet/netronome/nfp/nfp_net.h        |  3 +++
>  drivers/net/ethernet/netronome/nfp/nfp_net_common.c | 21 ++++++++++-----------
>  2 files changed, 13 insertions(+), 11 deletions(-)
> 
> diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net.h b/drivers/net/ethernet/netronome/nfp/nfp_net.h
> index 66319a1026bb..7b9518cbe965 100644
> --- a/drivers/net/ethernet/netronome/nfp/nfp_net.h
> +++ b/drivers/net/ethernet/netronome/nfp/nfp_net.h
> @@ -117,6 +117,9 @@ struct nfp_eth_table_port;
>  struct nfp_net;
>  struct nfp_net_r_vector;
>  
> +/* Convenience macro for wrapping descriptor index on ring size */
> +#define D_IDX(ring, idx)	((idx) & ((ring)->cnt - 1))

Any reason not to make this a function?

That notwithstanding:

Reviewed-by: Simon Horman <simon.horman@netronome.com>
