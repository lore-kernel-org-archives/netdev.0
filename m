From: Fabio Estevam <festevam@gmail.com>
Subject: Re: NFS does not work on linux-next 20140331
Date: Mon, 31 Mar 2014 13:35:48 -0300
Message-ID: <CAOMZO5Ac2s9bA8Af+ObDOR+5q0FJAnQ9RoGRO62tCpMvK-npbg@mail.gmail.com>
References: <CAOMZO5DQ3dNB-R5rsd2X89XLbg_VYs7za8xQT2K-bWWmFS=YHA@mail.gmail.com>
	<1396283344.29410.55.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f43.google.com ([74.125.82.43]:41235 "EHLO
	mail-wg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752640AbaCaQfu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Mar 2014 12:35:50 -0400
Received: by mail-wg0-f43.google.com with SMTP id x13so6070877wgg.26
        for <netdev@vger.kernel.org>; Mon, 31 Mar 2014 09:35:49 -0700 (PDT)
In-Reply-To: <1396283344.29410.55.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

On Mon, Mar 31, 2014 at 1:29 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Hi Fabio
>
> Could you try the following patch ?
>
> diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
> index e1e47350784b..74a774af8265 100644
> --- a/net/ipv6/mcast.c
> +++ b/net/ipv6/mcast.c
> @@ -1588,7 +1588,7 @@ static void mld_sendpack(struct sk_buff *skb)
>
>         rcu_read_lock();
>         idev = __in6_dev_get(skb->dev);
> -       IP6_UPD_PO_STATS(net, idev, IPSTATS_MIB_OUT, skb->len);
> +       IP6_UPD_PO_STATS_BH(net, idev, IPSTATS_MIB_OUT, skb->len);

Thanks for the suggestion, but still get the same problem.
