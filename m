From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH nf-next,v2] gtp: add initial driver for datapath of GPRS
 Tunneling Protocol (GTP-U)
Date: Tue, 10 May 2016 22:24:56 -0700
Message-ID: <CAM_iQpX+KDStq7cdW=YLpRUS-xceXbn8yW52ia1fwagiUBXr2Q@mail.gmail.com>
References: <1462748148-17764-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>, laforge@gnumonks.org,
	aschultz@tpip.net, openbsc@lists.osmocom.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f195.google.com ([209.85.161.195]:36198 "EHLO
	mail-yw0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751157AbcEKFZQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 May 2016 01:25:16 -0400
Received: by mail-yw0-f195.google.com with SMTP id u62so3127269ywe.3
        for <netdev@vger.kernel.org>; Tue, 10 May 2016 22:25:16 -0700 (PDT)
In-Reply-To: <1462748148-17764-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, May 8, 2016 at 3:55 PM, Pablo Neira Ayuso <pablo@netfilter.org> wrote:
> +static int gtp_genl_new_pdp(struct sk_buff *skb, struct genl_info *info)
> +{
...
> +
> +       net = gtp_genl_get_net(sock_net(skb->sk), info->attrs);
> +       if (IS_ERR(net))
> +               return PTR_ERR(net);
> +
> +       /* Check if there's an existing gtpX device to configure */
> +       dev = gtp_find_dev(net, nla_get_u32(info->attrs[GTPA_LINK]));
> +       if (dev == NULL)
> +               return -ENODEV;
> +
> +       return ipv4_pdp_add(dev, info);


Seems you are leaking struct net at least in the error path.
