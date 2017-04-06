From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net 1/1] net: tcp: Don't increase the TCP_MIB_OUTRSTS
 when fail to transmit RST
Date: Thu, 06 Apr 2017 08:24:27 -0700
Message-ID: <1491492267.10124.79.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1491485709-8269-1-git-send-email-gfree.wind@foxmail.com>
         <CADVnQymp9X3EwmiiocNHU8bQpg7Wb7FvGr4SduKjhLoTv35zMA@mail.gmail.com>
         <001301d2aede$e1e54f00$a5afed00$@foxmail.com>
         <CADVnQy=5GXBQzvDtbxQp-0ndJ1KphcxkY42mHsDPST0+sMGw2A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Gao Feng <gfree.wind@foxmail.com>,
        David Miller <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Patrick McHardy <kaber@trash.net>,
        Netdev <netdev@vger.kernel.org>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:32924 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753313AbdDFPYa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Apr 2017 11:24:30 -0400
Received: by mail-io0-f195.google.com with SMTP id f84so4649786ioj.0
        for <netdev@vger.kernel.org>; Thu, 06 Apr 2017 08:24:30 -0700 (PDT)
In-Reply-To: <CADVnQy=5GXBQzvDtbxQp-0ndJ1KphcxkY42mHsDPST0+sMGw2A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-04-06 at 10:08 -0400, Neal Cardwell wrote:
> On Thu, Apr 6, 2017 at 10:05 AM, Gao Feng <gfree.wind@foxmail.com> wrote:
> > If so, we should increase the TCP_MIB_OUTRSTS too when fail to alloc skb.
> > When machine is overloaded and mem is exhausted, it may fail to alloc skb.
> 
> Moving the increment of TCP_MIB_OUTRSTS to the top of
> tcp_send_active_reset() sounds fine to me.


Yes.

Keep in mind that whatever hard we try to send the packet, something
might drop it later without TCP stack knowing it.

So it is not really useful to test the immediate actions that are under
our control.
