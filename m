From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH net-next v2 9/9] nfp: add control message passing
 capabilities to flower offloads
Date: Thu, 29 Jun 2017 16:46:58 +0300
Message-ID: <CAJ3xEMjaaCWZ7gMaRVj-WRV5rcUc1JLwQZrQZihxjbg21uXTbA@mail.gmail.com>
References: <1498681802-2897-1-git-send-email-simon.horman@netronome.com> <1498681802-2897-10-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: David Miller <davem@davemloft.net>,
        Jakub Kicinski <jakub.kicinski@netronome.com>,
        Linux Netdev List <netdev@vger.kernel.org>,
        oss-drivers@netronome.com,
        Pieter Jansen van Vuuren
        <pieter.jansenvanvuuren@netronome.com>
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f65.google.com ([209.85.218.65]:34743 "EHLO
        mail-oi0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752807AbdF2Nq7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Jun 2017 09:46:59 -0400
Received: by mail-oi0-f65.google.com with SMTP id d77so8818947oig.1
        for <netdev@vger.kernel.org>; Thu, 29 Jun 2017 06:46:59 -0700 (PDT)
In-Reply-To: <1498681802-2897-10-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 28, 2017 at 11:30 PM, Simon Horman
<simon.horman@netronome.com> wrote:
> From: Pieter Jansen van Vuuren <pieter.jansenvanvuuren@netronome.com>

> +nfp_flower_xmit_flow(struct net_device *netdev,
> +                    struct nfp_fl_payload *nfp_flow, u8 mtype)
> +{
> +       u32 meta_len, key_len, mask_len, act_len, tot_len;
> +       struct nfp_repr *priv = netdev_priv(netdev);
> +       struct sk_buff *skb;
> +       unsigned char *msg;
> +
> +       meta_len =  sizeof(struct nfp_fl_rule_metadata);
> +       key_len = nfp_flow->meta.key_len;
> +       mask_len = nfp_flow->meta.mask_len;
> +       act_len = nfp_flow->meta.act_len;
> +
> +       tot_len = meta_len + key_len + mask_len + act_len;
> +
> +       /* Convert to long words as firmware expects
> +        * lengths in units of NFP_FL_LW_SIZ.
> +        */
> +       nfp_flow->meta.key_len /= NFP_FL_LW_SIZ;
> +       nfp_flow->meta.mask_len /= NFP_FL_LW_SIZ;
> +       nfp_flow->meta.act_len /= NFP_FL_LW_SIZ;

better to use use x >>= 2 instead x /= 4

I saw it in other places across the patch/set
