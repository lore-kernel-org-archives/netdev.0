From: Xi Wang <xii@google.com>
Subject: Re: [PATCH] net-tun: restructure tun_do_read for better sleep/wakeup efficiency
Date: Thu, 8 May 2014 23:34:17 -0700
Message-ID: <CAOBoifhdj2bqZXQ3ikFv_W4YWX8N0b_YNEAe+j=emXSYMfR84w@mail.gmail.com>
References: <1399422244-22751-1-git-send-email-xii@google.com>
	<5369AB36.6030609@redhat.com>
	<CAOBoifh6X8nbiqcNXNxJeFzWj1Q3N9Jc-xxQNrLWwFQf8LjZzQ@mail.gmail.com>
	<536C4733.9020704@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Maxim Krasnyansky <maxk@qti.qualcomm.com>,
	Neal Cardwell <ncardwell@google.com>,
	Eric Dumazet <edumazet@google.com>
To: Jason Wang <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f178.google.com ([209.85.217.178]:55476 "EHLO
	mail-lb0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752110AbaEIGeT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 May 2014 02:34:19 -0400
Received: by mail-lb0-f178.google.com with SMTP id w7so5023314lbi.23
        for <netdev@vger.kernel.org>; Thu, 08 May 2014 23:34:18 -0700 (PDT)
In-Reply-To: <536C4733.9020704@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>>> +     /* Read frames from queue */
>>>> +     skb = __skb_recv_datagram(tfile->socket.sk, noblock ? MSG_DONTWAIT : 0,
>>>> +                               &peeked, &off, &err);
>>>> +     if (skb) {
>>> This changes the userspace ABI a little bit. Originally, userspace can
>>> see different error codes and do responds, but here it can only see zero.
>>
>> Thanks for catching this! Seems forwarding the &err parameter of
>> __skb_recv_datagram
>> should get the most of the error code compatibility back?
>
> Seems not, -ERESTARTSYS and EIO were missed.

-ERESTARTSYS would be returned through sock_intr_errno ->
wait_for_more_packets -> __skb_recv_datagram., -EIO would still be
missing.

-Xi
