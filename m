From: Greg <gvrose8192@gmail.com>
Subject: Re: [net 4/4] i40e: fix call of ndo_dflt_bridge_getlink()
Date: Thu, 27 Oct 2016 15:13:39 -0700
Message-ID: <1477606419.3832.1.camel@gmail.com>
References: <1477603677-39957-1-git-send-email-jeffrey.t.kirsher@intel.com>
         <1477603677-39957-5-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Huaibin Wang <huaibin.wang@6wind.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, guru.anbalagane@oracle.com,
        Carolyn Wyborny <carolyn.wyborny@intel.com>,
        Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:35341 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1034172AbcJ0WNl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Oct 2016 18:13:41 -0400
Received: by mail-pf0-f193.google.com with SMTP id s8so3678634pfj.2
        for <netdev@vger.kernel.org>; Thu, 27 Oct 2016 15:13:41 -0700 (PDT)
In-Reply-To: <1477603677-39957-5-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-10-27 at 14:27 -0700, Jeff Kirsher wrote:
> From: Huaibin Wang <huaibin.wang@6wind.com>
> 
> Order of arguments is wrong.
> The wrong code has been introduced by commit 7d4f8d871ab1, but is compiled
> only since commit 9df70b66418e.
> 
> Note that this may break netlink dumps.
> 
> Fixes: 9df70b66418e ("i40e: Remove incorrect #ifdef's")
> Fixes: 7d4f8d871ab1 ("switchdev; add VLAN support for port's bridge_getlink")
> CC: Carolyn Wyborny <carolyn.wyborny@intel.com>
> Signed-off-by: Huaibin Wang <huaibin.wang@6wind.com>
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>  drivers/net/ethernet/intel/i40e/i40e_main.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
> index 6abc130..31c97e3 100644
> --- a/drivers/net/ethernet/intel/i40e/i40e_main.c
> +++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
> @@ -9034,7 +9034,7 @@ static int i40e_ndo_bridge_getlink(struct sk_buff *skb, u32 pid, u32 seq,
>  		return 0;
>  
>  	return ndo_dflt_bridge_getlink(skb, pid, seq, dev, veb->bridge_mode,
> -				       nlflags, 0, 0, filter_mask, NULL);
> +				       0, 0, nlflags, filter_mask, NULL);

Yikes!  And NDO function with 10 parameters?  No wonder they get mixed
up.

- Greg

>  }
>  
>  /* Hardware supports L4 tunnel length of 128B (=2^7) which includes
