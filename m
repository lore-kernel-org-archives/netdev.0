From: Fabio Estevam <festevam@gmail.com>
Subject: Re: NFS does not work on linux-next 20140331
Date: Mon, 31 Mar 2014 13:50:58 -0300
Message-ID: <CAOMZO5AQQoQK_2SM7QwfRYePKmf0Ci1=yMfH7reRwm_hWAVEyg@mail.gmail.com>
References: <CAOMZO5DQ3dNB-R5rsd2X89XLbg_VYs7za8xQT2K-bWWmFS=YHA@mail.gmail.com>
	<1396283344.29410.55.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAOMZO5Ac2s9bA8Af+ObDOR+5q0FJAnQ9RoGRO62tCpMvK-npbg@mail.gmail.com>
	<20140331164301.GA24150@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: Fabio Estevam <festevam@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f179.google.com ([74.125.82.179]:41008 "EHLO
	mail-we0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752958AbaCaQu7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Mar 2014 12:50:59 -0400
Received: by mail-we0-f179.google.com with SMTP id x48so4942291wes.24
        for <netdev@vger.kernel.org>; Mon, 31 Mar 2014 09:50:58 -0700 (PDT)
In-Reply-To: <20140331164301.GA24150@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 31, 2014 at 1:43 PM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:

> Would you be able to quickly test this one?
>
> diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
> index e1e4735..08b367c 100644
> --- a/net/ipv6/mcast.c
> +++ b/net/ipv6/mcast.c
> @@ -1620,11 +1620,12 @@ static void mld_sendpack(struct sk_buff *skb)
>                       dst_output);
>  out:
>         if (!err) {
> -               ICMP6MSGOUT_INC_STATS_BH(net, idev, ICMPV6_MLD2_REPORT);
> -               ICMP6_INC_STATS_BH(net, idev, ICMP6_MIB_OUTMSGS);
> -               IP6_UPD_PO_STATS_BH(net, idev, IPSTATS_MIB_OUTMCAST, payload_len);
> -       } else
> -               IP6_INC_STATS_BH(net, idev, IPSTATS_MIB_OUTDISCARDS);
> +               ICMP6MSGOUT_INC_STATS(net, idev, ICMPV6_MLD2_REPORT);
> +               ICMP6_INC_STATS(net, idev, ICMP6_MIB_OUTMSGS);
> +               IP6_UPD_PO_STATS(net, idev, IPSTATS_MIB_OUTMCAST, payload_len);
> +       } else {
> +               IP6_INC_STATS(net, idev, IPSTATS_MIB_OUTDISCARDS);
> +       }

Thanks, Hannes. This makes NFS-mount to work fine again:

Tested-by: Fabio Estevam <fabio.estevam@freescale.com>
