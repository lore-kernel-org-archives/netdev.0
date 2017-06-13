From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [PATCH net-next 1/1] net: reflect mark on tcp syn ack packets
Date: Tue, 13 Jun 2017 09:34:07 +0900
Message-ID: <CAKD1Yr1GcK3XQpyx=p-EHWXHax_+-HXpHFT6uWZY_9ovv8V7mA@mail.gmail.com>
References: <1497101461-20921-1-git-send-email-jhs@emojatatu.com>
 <20170610.190213.1437094451353913622.davem@davemloft.net> <056cbd5c-2a5f-8767-e584-591f39bc2029@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: David Miller <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        mrv@mojatatu.com, hadi@mojatatu.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f45.google.com ([209.85.213.45]:33299 "EHLO
        mail-vk0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752508AbdFMAe3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Jun 2017 20:34:29 -0400
Received: by mail-vk0-f45.google.com with SMTP id p62so56316185vkp.0
        for <netdev@vger.kernel.org>; Mon, 12 Jun 2017 17:34:29 -0700 (PDT)
In-Reply-To: <056cbd5c-2a5f-8767-e584-591f39bc2029@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jun 11, 2017 at 8:58 PM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
>> Maybe this should both be "inet_request_mark()"?
>>
>
> Challenge is making of a synack requires a new allocated skb;
> and sk is a listening socket - which should/has a mark of
> 0 meaning at ip_build_and_send_pkt() it overrides
> the value already set on the skb->mark.

As David says, the tcp_fwmark_accept sysctl is not really appropriate
for synack packets - what it does is ensure that when a connection is
accepted, sk->sk_mark is set to the mark of the incoming skb.

I think the correct behaviour here is to to honour the
ip_fwmark_reflect sysctl instead, and if it's enabled, make the synack
mark be the same as the the incoming syn mark.
