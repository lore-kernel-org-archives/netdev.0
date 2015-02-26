From: Eyal Birger <eyal.birger@gmail.com>
Subject: Re: [PATCH net-next 3/7] net: rxrpc: change call to
 sock_recv_ts_and_drops() on rxrpc recvmsg to sock_recv_timestamp()
Date: Thu, 26 Feb 2015 16:55:58 +0200
Message-ID: <CAHsH6Gstyh+8TRqONtfST9V6-_=LNSvQekfGtJFmPWLZ9onZPw@mail.gmail.com>
References: <1424916612-744-1-git-send-email-eyal.birger@gmail.com>
	<1424916612-744-4-git-send-email-eyal.birger@gmail.com>
	<1424925652.5565.145.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAHsH6Gup09dtVZEi-vmp5ep_rs1ELueDudMJy1084e5vDbqJ0Q@mail.gmail.com>
	<1424961066.5565.151.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Willem de Bruijn <willemb@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Shmulik Ladkani <shmulik.ladkani@gmail.com>,
	Marcel Holtmann <marcel@holtmann.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f52.google.com ([209.85.213.52]:44332 "EHLO
	mail-yh0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753432AbbBZOz7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2015 09:55:59 -0500
Received: by yhaf73 with SMTP id f73so4671200yha.11
        for <netdev@vger.kernel.org>; Thu, 26 Feb 2015 06:55:58 -0800 (PST)
In-Reply-To: <1424961066.5565.151.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 26, 2015 at 4:31 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Thu, 2015-02-26 at 09:30 +0200, Eyal Birger wrote:
>
>> Maybe I didn't understand your comment. Note this patch does not fix
>> SO_RXQ_OVFL on rxrpc sockets.
>>
>> I essentially reverted 3b885787ea4112 for these sockets.
>>
>> It may be possible to compact rxrpc skb->cb[] usage by tricking the size
>> of the resend_at variable as you suggested.
>>
>> However, since SO_RXQ_OVFL never really worked on these sockets,
>> I limited the patch series scope to moving skb->dropcount; This patch only
>> signals that rxrpc can't support this feature unless some space is freed in its
>> skb->cb[] use.
>> --
>
> My point is : If you stick this patch early in the serie, then skb->mark
> will be overwritten by sock_recv_timestamp() (to store skb->dropcount)
> and rxrpc breaks as it actively relies on skb->mark (apparently)
>

skb->dropcount is stored prior to enqueue in sock_queue_rcv_skb().
This function is not called in rxrpc.

sock_recv_timestamp() is called from the recvmsg code, and does not alter
skb->dropcount.

What am I missing?

> We dont care if SO_RXQ_OVFL is broken for rxprpc : Nobody noticed yet.
>

This was my point in this patch - to make it explicit. When rxrpc called
sock_recv_ts_and_drops() it allegedly supported receiving drops, when
dropcount was never set.

> But breaking rxrpc skb->mark early in the serie does not help bisection
> if needed later.
>
