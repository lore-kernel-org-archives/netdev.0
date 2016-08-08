From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [PATCH net] net: ipv6: Fix ping to link-local addresses.
Date: Mon, 8 Aug 2016 23:45:44 +0900
Message-ID: <CAKD1Yr2yeVbue0ygRd2av+_nrTaq2cOtD=ZNJT7H25CqXr-=zg@mail.gmail.com>
References: <1470642127-574-1-git-send-email-lorenzo@google.com> <7ff321ea-87f7-4a59-0e1e-52962d4e9be6@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Erik Kline <ek@google.com>, David Miller <davem@davemloft.net>,
	=?UTF-8?B?5ZCJ6Jek6Iux5piO?= <hideaki.yoshifuji@miraclelinux.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f182.google.com ([209.85.223.182]:32880 "EHLO
	mail-io0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751798AbcHHOqG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Aug 2016 10:46:06 -0400
Received: by mail-io0-f182.google.com with SMTP id 38so359615979iol.0
        for <netdev@vger.kernel.org>; Mon, 08 Aug 2016 07:46:05 -0700 (PDT)
In-Reply-To: <7ff321ea-87f7-4a59-0e1e-52962d4e9be6@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 8, 2016 at 11:26 PM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
>> -             if (sk->sk_bound_dev_if &&
>> -                 sk->sk_bound_dev_if != u->sin6_scope_id) {
>> -                     return -EINVAL;
>> -             }
>
> Hmm, sk->sk_bound_dev_if always has highest prio for the selection of
> the output interface. Thus this code made sense to me.

Removing it is consistent with the other sendmsg functions such as
udpv6_sendmsg or rawv6_sendmsg.

There is similar code in __ip6_datagram_connect, but that seems a bit
different because that code also *sets* sk_bound_dev_if.

Personally I think it's better for pingv6_sendmsg be consistent with
the other *_sendmsg functions than with ip6_datagram_connect, and thus
the code should be removed. But I don't feel particularly strongly
about it.
