From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH net] VXLAN: fix potential NULL dereference in arp_reduce()
Date: Tue, 18 Mar 2014 09:53:09 -0700
Message-ID: <CAHA+R7O+Njk2vbfEg+RfrRJ=x1JdXTheZQwhu4PpU47Bgk2CHQ@mail.gmail.com>
References: <201403181632.s2IGWTjT003613@lab1.dls>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev <netdev@vger.kernel.org>
To: David L Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f171.google.com ([209.85.217.171]:49170 "EHLO
	mail-lb0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753933AbaCRQxL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Mar 2014 12:53:11 -0400
Received: by mail-lb0-f171.google.com with SMTP id w7so4949704lbi.2
        for <netdev@vger.kernel.org>; Tue, 18 Mar 2014 09:53:10 -0700 (PDT)
In-Reply-To: <201403181632.s2IGWTjT003613@lab1.dls>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 18, 2014 at 9:32 AM, David L Stevens <dlstevens@us.ibm.com> wrote:
>
>         This patch fixes a NULL pointer dereference in the event of an
> skb allocation failure in arp_reduce().
>
> Signed-Off-By: David L Stevens <dlstevens@us.ibm.com>
>
> diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
> index eb59b14..570792c 100644
> --- a/drivers/net/vxlan.c
> +++ b/drivers/net/vxlan.c
> @@ -1315,6 +1315,9 @@ static int arp_reduce(struct net_device *dev, struct sk_buff *skb)
>
>                 neigh_release(n);
>
> +               if (reply == NULL)
> +                       goto out;
> +

Nit: move it right after arp_create(). Otherwise:

Acked-by: Cong Wang <cwang@twopensource.com>
