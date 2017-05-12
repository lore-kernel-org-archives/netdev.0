From: Michael Chan <michael.chan@broadcom.com>
Subject: Re: [Problem] Broadcom BCM5762 Ethernet tg3 times out with stack trace
Date: Fri, 12 May 2017 14:45:28 -0700
Message-ID: <CACKFLi=762N5LzmcOE4dPS_1Op8EsJ8QJBRFqZySaSx7SNb1bg@mail.gmail.com>
References: <CAMet4B7c_wT3rk2DBcTBmdMpPpHuiuWSEae=VLrVH_tfcZT1_g@mail.gmail.com>
 <CANeD+K_ojPPUS2QtHRg+1o4EZaCSFcaa=dDPfkR2tUYNwdGNiw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Siva Reddy Kallam <siva.kallam@broadcom.com>,
        Prashant Sreedharan <prashant@broadcom.com>,
        Michael Chan <mchan@broadcom.com>,
        Linux Netdev List <netdev@vger.kernel.org>
To: Daniel Kim <dkim@playmechanix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f54.google.com ([209.85.215.54]:33725 "EHLO
        mail-lf0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751505AbdELVpa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 12 May 2017 17:45:30 -0400
Received: by mail-lf0-f54.google.com with SMTP id r17so7766461lfg.0
        for <netdev@vger.kernel.org>; Fri, 12 May 2017 14:45:30 -0700 (PDT)
In-Reply-To: <CANeD+K_ojPPUS2QtHRg+1o4EZaCSFcaa=dDPfkR2tUYNwdGNiw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 12, 2017 at 12:10 PM, Daniel Kim <dkim@playmechanix.com> wrote:

> [ 4898.361530] tg3 0000:04:00.0 enp4s0: 0: Host status block
> [00000001:00000021:(0000:0486:0000):(0000:002c)]
> [ 4898.361535] tg3 0000:04:00.0 enp4s0: 0: NAPI info
> [00000021:00000021:(0135:002c:01ff):0000:(0568:0000:0000:0000)]

As you can see here, the driver has caught up with the hardware's
status tag of 0x21 and tx consumer of 0x2c.  However, the tx producer
is at 0x135, way ahead of the consumer.  The hardware is not
completing all these TX BDs from 0x2c to 0x135.

> [ 4898.360797] tg3 0000:04:00.0 enp4s0: 0x00000c00: 0x0000000a,
> 0x00000000, 0x00000003, 0x00000001
>
> [ 4898.360849] tg3 0000:04:00.0 enp4s0: 0x00001800: 0x00000016,
> 0x00000000, 0x00000135, 0x00000000
>
> [ 4898.361157] tg3 0000:04:00.0 enp4s0: 0x00004800: 0x380303fe,
> 0x00000000, 0x00000000, 0x00000100

I checked a few of the status registers related to the TX blocks and
the read DMA engine status and they are all ok.  The hardware sees the
tx producer of 0x135.

> [ 4898.361087] tg3 0000:04:00.0 enp4s0: 0x00003cc0: 0x00000135,
0x00000000, 0x00000000, 0x00000000

Even the internal host coalescing is seeing 0x135 as the tx index.
Somehow this is not DMA'ed to the host.

Do you have IOMMU enabled?  Does the same NIC used to work with a
different kernel?
