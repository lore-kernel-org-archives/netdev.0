From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH net-next v2 5/9] nfp: extend flower matching capabilities
Date: Thu, 29 Jun 2017 17:00:06 +0200
Message-ID: <20170629150004.GB6215@vergenet.net>
References: <1498681802-2897-1-git-send-email-simon.horman@netronome.com>
 <1498681802-2897-6-git-send-email-simon.horman@netronome.com>
 <CAJ3xEMhnp5JE6QPok4nJGGfdP2diEBtA0_9Q2K2OpHJD_Wi-FQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
        Jakub Kicinski <jakub.kicinski@netronome.com>,
        Linux Netdev List <netdev@vger.kernel.org>,
        oss-drivers@netronome.com,
        Pieter Jansen van Vuuren
        <pieter.jansenvanvuuren@netronome.com>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f171.google.com ([209.85.216.171]:36708 "EHLO
        mail-qt0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751974AbdF2PAS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Jun 2017 11:00:18 -0400
Received: by mail-qt0-f171.google.com with SMTP id i2so76538911qta.3
        for <netdev@vger.kernel.org>; Thu, 29 Jun 2017 08:00:18 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAJ3xEMhnp5JE6QPok4nJGGfdP2diEBtA0_9Q2K2OpHJD_Wi-FQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 29, 2017 at 05:33:32PM +0300, Or Gerlitz wrote:
> On Wed, Jun 28, 2017 at 11:29 PM, Simon Horman
> <simon.horman@netronome.com> wrote:
> > +nfp_flower_compile_meta_tci(struct nfp_flower_meta_two *frame,
> > +                           struct tc_cls_flower_offload *flow, u8 key_type,
> > +                           bool mask_version)
> 
> what's the role of the mask_version flag here and elsewhere in the
> sister functions?

Hi Or,

I chatted with Pieter about this and my understanding is that metadata
comes in pairs; masked and umasked. The mask_version parameter controls
which of the pair is compiled.

> 
> > +{
> > +       struct flow_dissector_key_vlan *flow_vlan;
> > +       u16 tmp_tci;
> > +
> > +       /* Populate the metadata frame. */
> > +       frame->nfp_flow_key_layer = key_type;
> > +       frame->mask_id = ~0;
> > +
> > +       if (mask_version) {
> > +               frame->tci = cpu_to_be16(~0);
> > +               return;
> > +       }
> > +
