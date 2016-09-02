From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] switchdev: Fix return value of
 switchdev_port_fdb_dump().
Date: Fri, 02 Sep 2016 06:48:01 -0700
Message-ID: <1472824081.5439.17.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1472814717-11339-1-git-send-email-rami.rosen@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        roopa@cumulusnetworks.com, wkok@cumulusnetworks.com
To: Rami Rosen <rami.rosen@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f67.google.com ([209.85.220.67]:33792 "EHLO
        mail-pa0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752777AbcIBNsE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Sep 2016 09:48:04 -0400
Received: by mail-pa0-f67.google.com with SMTP id hm5so1073367pac.1
        for <netdev@vger.kernel.org>; Fri, 02 Sep 2016 06:48:03 -0700 (PDT)
In-Reply-To: <1472814717-11339-1-git-send-email-rami.rosen@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-09-02 at 14:11 +0300, Rami Rosen wrote:
> This patch fixes the retun value of switchdev_port_fdb_dump() when
> CONFIG_NET_SWITCHDEV is not set. This avoids getting "warning: return makes
> integer from pointer without a cast [-Wint-conversion]" when building
> when CONFIG_NET_SWITCHDEV is not set under several compiler versions.
> This warning is due to commit d297653dd6f07afbe7e6c702a4bcd7615680002e
> ("rtnetlink: fdb dump: optimize by saving last interface markers").
> 
> Signed-off-by: Rami Rosen <rami.rosen@intel.com>
> ---
>  include/net/switchdev.h | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/include/net/switchdev.h b/include/net/switchdev.h
> index 6279f2f..729fe15 100644
> --- a/include/net/switchdev.h
> +++ b/include/net/switchdev.h
> @@ -344,7 +344,7 @@ static inline int switchdev_port_fdb_dump(struct sk_buff *skb,
>  					  struct net_device *filter_dev,
>  					  int *idx)
>  {
> -       return idx;
> +       return *idx;
>  }
>  
>  static inline bool switchdev_port_same_parent_id(struct net_device *a,


Thanks a lot Rami !

Reported-by: Eric Dumazet <edumazet@google.com>
