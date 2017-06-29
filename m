From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH net-next v2 5/9] nfp: extend flower matching capabilities
Date: Thu, 29 Jun 2017 17:33:32 +0300
Message-ID: <CAJ3xEMhnp5JE6QPok4nJGGfdP2diEBtA0_9Q2K2OpHJD_Wi-FQ@mail.gmail.com>
References: <1498681802-2897-1-git-send-email-simon.horman@netronome.com> <1498681802-2897-6-git-send-email-simon.horman@netronome.com>
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
Received: from mail-oi0-f52.google.com ([209.85.218.52]:35752 "EHLO
        mail-oi0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751974AbdF2Odd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Jun 2017 10:33:33 -0400
Received: by mail-oi0-f52.google.com with SMTP id c189so67854515oia.2
        for <netdev@vger.kernel.org>; Thu, 29 Jun 2017 07:33:32 -0700 (PDT)
In-Reply-To: <1498681802-2897-6-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 28, 2017 at 11:29 PM, Simon Horman
<simon.horman@netronome.com> wrote:
> +nfp_flower_compile_meta_tci(struct nfp_flower_meta_two *frame,
> +                           struct tc_cls_flower_offload *flow, u8 key_type,
> +                           bool mask_version)

what's the role of the mask_version flag here and elsewhere in the
sister functions?

> +{
> +       struct flow_dissector_key_vlan *flow_vlan;
> +       u16 tmp_tci;
> +
> +       /* Populate the metadata frame. */
> +       frame->nfp_flow_key_layer = key_type;
> +       frame->mask_id = ~0;
> +
> +       if (mask_version) {
> +               frame->tci = cpu_to_be16(~0);
> +               return;
> +       }
> +
