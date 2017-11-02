From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] tcp: Always cleanup skb before sending
Date: Wed, 01 Nov 2017 18:00:10 -0700
Message-ID: <1509584410.3828.64.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20171101211001.57901-1-cpaasch@apple.com>
         <CANn89iLv+0+A79-pNu8HZ2kBbyNt2ini2Zjbm++s9TT7mtOamw@mail.gmail.com>
         <1509573218.3828.54.camel@edumazet-glaptop3.roam.corp.google.com>
         <20171102001035.GR44287@da0602a-dhcp105.apple.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
        David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>
To: Christoph Paasch <cpaasch@apple.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:46554 "EHLO
        mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751646AbdKBBAN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2017 21:00:13 -0400
Received: by mail-pf0-f179.google.com with SMTP id p87so3278339pfj.3
        for <netdev@vger.kernel.org>; Wed, 01 Nov 2017 18:00:13 -0700 (PDT)
In-Reply-To: <20171102001035.GR44287@da0602a-dhcp105.apple.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-11-01 at 17:10 -0700, Christoph Paasch wrote:

> Yes, that looks good to me. Thanks!
> 
> But we still need to clean up the skb in tcp_v4_send_reset and
> tcp_v4_send_ack, as the fields (e.g., tcp_skb_cb->seq) have been set when
> coming from tcp_v4_rcv.

You might be confused : ip_send_unicast_reply() does not send back the
incoming skb.

A fresh skb is allocated, then appended/sent.

And commit 24a2d43d8886f5a29c did the changes to provide to
__ip_options_echo() the proper IPCB header location.
