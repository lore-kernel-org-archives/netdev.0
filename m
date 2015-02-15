From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH net-next] net: Reflect RX hash for transmit
Date: Sun, 15 Feb 2015 12:19:34 -0800
Message-ID: <CA+mtBx-Mp5k4TmoDK29ui=jB79drq-K-vhPqK3GgFNoqA2Mifg@mail.gmail.com>
References: <1424025438-1659-1-git-send-email-therbert@google.com>
	<54E0FAA1.7000900@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f176.google.com ([209.85.213.176]:53623 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755264AbbBOUTf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Feb 2015 15:19:35 -0500
Received: by mail-ig0-f176.google.com with SMTP id hl2so20019449igb.3
        for <netdev@vger.kernel.org>; Sun, 15 Feb 2015 12:19:35 -0800 (PST)
In-Reply-To: <54E0FAA1.7000900@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Feb 15, 2015 at 11:59 AM, Daniel Borkmann <daniel@iogearbox.net> wrote:
> On 02/15/2015 07:37 PM, Tom Herbert wrote:
>>
>> This patch allows a driver to request that the receive hash it provides
>> to the stack is reflected back in skb->hash for packets transmitted
>> on the associated connection.
>
> [...]
>>
>> +       if (unlikely(skb->reflect_hash && sk->sk_txhash != skb->hash))
>> +               sk->sk_txhash = skb->hash;
>
>
> Is there also an initial user setting this somewhere?

inet_set_txhash and ip6_set_txhash are called for connected sockets.
There is no user API to set these.

Tom
