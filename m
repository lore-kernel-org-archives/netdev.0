From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: BUG:af_packet fails to TX TSO frames
Date: Wed, 11 Oct 2017 12:26:22 -0400
Message-ID: <CAF=yD-+JaS8JwEC2TyUG=Ebaho-MM+gjumrbHYM-H0EK1Hu62Q@mail.gmail.com>
References: <c3002d4f-62ff-1d0b-65fb-b366be45a6d8@cambridgegreys.com>
 <CAF=yD-+SxQTHxiU5Yi2f8dm6X1s7SA6PdkbeJP-K_9ZuTMAaTA@mail.gmail.com>
 <f2fe3f46-2ef1-0029-1c44-3576ca19d34b@cambridgegreys.com> <844d6e0f-6ee7-74bc-b961-faa77b240303@cambridgegreys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Network Development <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>
To: Anton Ivanov <anton.ivanov@cambridgegreys.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f50.google.com ([209.85.218.50]:44972 "EHLO
        mail-oi0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751462AbdJKQ1E (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2017 12:27:04 -0400
Received: by mail-oi0-f50.google.com with SMTP id v132so4017341oie.1
        for <netdev@vger.kernel.org>; Wed, 11 Oct 2017 09:27:03 -0700 (PDT)
In-Reply-To: <844d6e0f-6ee7-74bc-b961-faa77b240303@cambridgegreys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 11, 2017 at 11:54 AM, Anton Ivanov
<anton.ivanov@cambridgegreys.com> wrote:
> It is that patch.
>
> I rolled it back and immediately got it to work correctly on a Broadcom
> Tigon. I can test on all other scenarios, I have tried, I suspect it will
> come back alive on all of them.
>
> I am going to try to trace it through and see exactly where it drops a skb
> which the card has no issues in accepting.

It might be in the initialization of gso_type and csum. The virtio_net_hdr
can encode various combinations of flags that are not allowed by the
validation logic.
