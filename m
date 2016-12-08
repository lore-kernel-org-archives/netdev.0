From: Eric Dumazet <edumazet@google.com>
Subject: Re: [PATCH v2 net-next 4/4] udp: add batching to udp_rmem_release()
Date: Thu, 8 Dec 2016 10:36:22 -0800
Message-ID: <CANn89iL8r9UD=sGn3WxVFZ+Z_QJYYM6aXxCFvafwvJ-bEtNhKQ@mail.gmail.com>
References: <1481218739-27089-1-git-send-email-edumazet@google.com>
 <1481218739-27089-5-git-send-email-edumazet@google.com> <1481221491.6120.11.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S . Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f169.google.com ([209.85.223.169]:33613 "EHLO
        mail-io0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932109AbcLHSgY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Dec 2016 13:36:24 -0500
Received: by mail-io0-f169.google.com with SMTP id d9so15486271ioe.0
        for <netdev@vger.kernel.org>; Thu, 08 Dec 2016 10:36:24 -0800 (PST)
In-Reply-To: <1481221491.6120.11.camel@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 8, 2016 at 10:24 AM, Paolo Abeni <pabeni@redhat.com> wrote:

> Nice one! This sounds like a relevant improvement!
>
> I'm wondering if it may cause regressions with small value of
> sk_rcvbuf ?!? e.g. with:
>
> netperf -t UDP_STREAM  -H 127.0.0.1 -- -s 1280 -S 1280 -m 1024 -M 1024
>

Possibly, then simply we can refine the test to :

size = up->forward_deficit;
if (size < (sk->sk_rcvbuf >> 2)  && !skb_queue_empty(sk->sk_receive_buf))
     return;
