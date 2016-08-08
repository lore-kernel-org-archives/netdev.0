From: =?UTF-8?B?5ZCJ6Jek6Iux5piO?= <hideaki.yoshifuji@miraclelinux.com>
Subject: Re: [PATCH net] net: ipv6: Fix ping to link-local addresses.
Date: Tue, 9 Aug 2016 01:22:12 +0900
Message-ID: <CAPA1RqCQu8yQQTqrUUh+jcj9GT4OCh5EEbqU6mHjGiEzv0AP2w@mail.gmail.com>
References: <1470642127-574-1-git-send-email-lorenzo@google.com>
 <7ff321ea-87f7-4a59-0e1e-52962d4e9be6@stressinduktion.org> <CAKD1Yr2yeVbue0ygRd2av+_nrTaq2cOtD=ZNJT7H25CqXr-=zg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Erik Kline <ek@google.com>, David Miller <davem@davemloft.net>
To: Lorenzo Colitti <lorenzo@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f178.google.com ([209.85.223.178]:34714 "EHLO
	mail-io0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752152AbcHHQWN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Aug 2016 12:22:13 -0400
Received: by mail-io0-f178.google.com with SMTP id q83so362935263iod.1
        for <netdev@vger.kernel.org>; Mon, 08 Aug 2016 09:22:13 -0700 (PDT)
In-Reply-To: <CAKD1Yr2yeVbue0ygRd2av+_nrTaq2cOtD=ZNJT7H25CqXr-=zg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

2016-08-08 23:45 GMT+09:00 Lorenzo Colitti <lorenzo@google.com>:
> On Mon, Aug 8, 2016 at 11:26 PM, Hannes Frederic Sowa
> <hannes@stressinduktion.org> wrote:
>>> -             if (sk->sk_bound_dev_if &&
>>> -                 sk->sk_bound_dev_if != u->sin6_scope_id) {
>>> -                     return -EINVAL;
>>> -             }
>>
>> Hmm, sk->sk_bound_dev_if always has highest prio for the selection of
>> the output interface. Thus this code made sense to me.
>
> Removing it is consistent with the other sendmsg functions such as
> udpv6_sendmsg or rawv6_sendmsg.
>
> There is similar code in __ip6_datagram_connect, but that seems a bit
> different because that code also *sets* sk_bound_dev_if.
>
> Personally I think it's better for pingv6_sendmsg be consistent with
> the other *_sendmsg functions than with ip6_datagram_connect, and thus
> the code should be removed. But I don't feel particularly strongly
> about it.

Following must be met, at least, IMHO.
- SO_BINDTODEVICE requires "root", which sets sk_bound_dev_if.
- sin6_scope_id and sk_bound_dev_if should match (if the address it
link-local address), or each or both should equal to 0.

I think it would make more sense if former setting wins...

--yoshfuji
