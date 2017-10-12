From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: BUG:af_packet fails to TX TSO frames
Date: Thu, 12 Oct 2017 12:30:44 -0400
Message-ID: <CAF=yD-+W2tyXqCS_ueZgu11BB8ON5hdKGOZQOWtfr+HfvqW=Sg@mail.gmail.com>
References: <c3002d4f-62ff-1d0b-65fb-b366be45a6d8@cambridgegreys.com>
 <f2fe3f46-2ef1-0029-1c44-3576ca19d34b@cambridgegreys.com> <844d6e0f-6ee7-74bc-b961-faa77b240303@cambridgegreys.com>
 <CAF=yD-+JaS8JwEC2TyUG=Ebaho-MM+gjumrbHYM-H0EK1Hu62Q@mail.gmail.com>
 <23ace6d6-afa7-9a3a-aa61-1245ee6c0498@kot-begemot.co.uk> <CAF=yD-+MCLAoP5=orUyG0tQjXykde++QrOdE7v44srR54yP32Q@mail.gmail.com>
 <d6c1cda2-f7df-9132-304d-075c62d4d83d@kot-begemot.co.uk> <CAF=yD-+gc5oQ=XT0+yw4Wt_h3rObETti3FvXm+V-nu=87zaMyA@mail.gmail.com>
 <1e9c4f8b-2eb6-24cf-764f-b0a98aa0d044@kot-begemot.co.uk> <40e87e75-742f-3542-b79e-1e7fee9b4485@cambridgegreys.com>
 <CAF=yD-+YUZdCCLXdQEG5AA0Pkrf-OrWGwySWf7mqH5BhO-Vr+g@mail.gmail.com>
 <2f973588-e193-86c1-a645-7a158b17ebdc@cambridgegreys.com> <529ff560-8230-c799-2948-fae711de382e@kot-begemot.co.uk>
 <CAF=yD-+q_h4SE0E9RjE59i2FDYZQ_wV+L6RQjE9B_fszen-y0A@mail.gmail.com>
 <f046dbf4-0b46-2d7c-c82c-fe9f50c11f71@cambridgegreys.com> <e301fbfd-a283-caa1-5915-8be15677ed74@cambridgegreys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Network Development <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>
To: Anton Ivanov <anton.ivanov@cambridgegreys.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f46.google.com ([209.85.218.46]:56393 "EHLO
        mail-oi0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751434AbdJLQbZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2017 12:31:25 -0400
Received: by mail-oi0-f46.google.com with SMTP id v9so9377336oif.13
        for <netdev@vger.kernel.org>; Thu, 12 Oct 2017 09:31:25 -0700 (PDT)
In-Reply-To: <e301fbfd-a283-caa1-5915-8be15677ed74@cambridgegreys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 12, 2017 at 11:44 AM, Anton Ivanov
<anton.ivanov@cambridgegreys.com> wrote:
> Found it.
>
> Two bugs canceling each other.
> The bind sequence in:  psock_txring_vnet.c is wrong.
>
> It does the following addr.sll_protocol =    htons(ETH_P_IP);
> before calling bind.
>
> If you set addr.sll_protocol to ETH_P_ALL where it should have been in the
> first place the test program blows up with -ENOBUFS

There is no such requirement that the socket should bind to ETH_P_ALL.

> I think what is happening is that this value is taken into account when
> looking at "what should I use to segment it with" in skb_mac_gso_segment
> which is invoked at the end of the verification chain which starts in
> packet_direct_xmit in af_packet.c

packet_snd sets skb->protocol based on the protocol that the packet
socket is bound to. Binding to ETH_P_IP is the right choice here.
