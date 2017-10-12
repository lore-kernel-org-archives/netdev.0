From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: BUG:af_packet fails to TX TSO frames
Date: Thu, 12 Oct 2017 09:39:43 -0400
Message-ID: <CAF=yD-+q_h4SE0E9RjE59i2FDYZQ_wV+L6RQjE9B_fszen-y0A@mail.gmail.com>
References: <c3002d4f-62ff-1d0b-65fb-b366be45a6d8@cambridgegreys.com>
 <CAF=yD-+SxQTHxiU5Yi2f8dm6X1s7SA6PdkbeJP-K_9ZuTMAaTA@mail.gmail.com>
 <f2fe3f46-2ef1-0029-1c44-3576ca19d34b@cambridgegreys.com> <844d6e0f-6ee7-74bc-b961-faa77b240303@cambridgegreys.com>
 <CAF=yD-+JaS8JwEC2TyUG=Ebaho-MM+gjumrbHYM-H0EK1Hu62Q@mail.gmail.com>
 <23ace6d6-afa7-9a3a-aa61-1245ee6c0498@kot-begemot.co.uk> <CAF=yD-+MCLAoP5=orUyG0tQjXykde++QrOdE7v44srR54yP32Q@mail.gmail.com>
 <d6c1cda2-f7df-9132-304d-075c62d4d83d@kot-begemot.co.uk> <CAF=yD-+gc5oQ=XT0+yw4Wt_h3rObETti3FvXm+V-nu=87zaMyA@mail.gmail.com>
 <1e9c4f8b-2eb6-24cf-764f-b0a98aa0d044@kot-begemot.co.uk> <40e87e75-742f-3542-b79e-1e7fee9b4485@cambridgegreys.com>
 <CAF=yD-+YUZdCCLXdQEG5AA0Pkrf-OrWGwySWf7mqH5BhO-Vr+g@mail.gmail.com>
 <2f973588-e193-86c1-a645-7a158b17ebdc@cambridgegreys.com> <529ff560-8230-c799-2948-fae711de382e@kot-begemot.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Anton Ivanov <anton.ivanov@cambridgegreys.com>,
        Network Development <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>
To: Anton Ivanov <anton.ivanov@kot-begemot.co.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f50.google.com ([209.85.218.50]:55138 "EHLO
        mail-oi0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751057AbdJLNkY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2017 09:40:24 -0400
Received: by mail-oi0-f50.google.com with SMTP id a132so1054652oih.11
        for <netdev@vger.kernel.org>; Thu, 12 Oct 2017 06:40:24 -0700 (PDT)
In-Reply-To: <529ff560-8230-c799-2948-fae711de382e@kot-begemot.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> If I produce a real vnet frame out of a live kernel frame using
> virtio_net_hdr_from_skb() and try to send it it fails on the check in
> af_packet, while succeeding for tap. If I remove the af_packet check the
> frame is accepted by the hardware too.
>
> If I produce it a synthetic frame + vnet header using the test program - it
> works. Go figure.

Besides looking at the raw frame bytes, also compare the setup
of virtio_net_header, as well as the tcp checksum field. The stack
expects the pseudo header to have already been calculated.

> I am going to continue digging into it.
>
> At the very least I now have a positive test case which uses the same
> semantics as my code so I have something to compare to.

Glad to hear that the test is helpful. I wrote it because I
have run into these exact same issues in the past.
