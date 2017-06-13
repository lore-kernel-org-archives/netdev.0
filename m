From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next 1/1] net: reflect mark on tcp syn ack packets
Date: Tue, 13 Jun 2017 07:33:40 -0400
Message-ID: <b6e180c2-b17d-38fd-27cc-6d92ff38e8dd@mojatatu.com>
References: <1497101461-20921-1-git-send-email-jhs@emojatatu.com>
 <20170610.190213.1437094451353913622.davem@davemloft.net>
 <056cbd5c-2a5f-8767-e584-591f39bc2029@mojatatu.com>
 <CAKD1Yr1GcK3XQpyx=p-EHWXHax_+-HXpHFT6uWZY_9ovv8V7mA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        mrv@mojatatu.com, hadi@mojatatu.com
To: Lorenzo Colitti <lorenzo@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:36488 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752109AbdFMLdn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Jun 2017 07:33:43 -0400
Received: by mail-io0-f195.google.com with SMTP id i93so12648069iod.3
        for <netdev@vger.kernel.org>; Tue, 13 Jun 2017 04:33:43 -0700 (PDT)
In-Reply-To: <CAKD1Yr1GcK3XQpyx=p-EHWXHax_+-HXpHFT6uWZY_9ovv8V7mA@mail.gmail.com>
Content-Language: en-GB
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-06-12 08:34 PM, Lorenzo Colitti wrote:
> On Sun, Jun 11, 2017 at 8:58 PM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
>>> Maybe this should both be "inet_request_mark()"?

> As David says, the tcp_fwmark_accept sysctl is not really appropriate
> for synack packets - what it does is ensure that when a connection is
> accepted, sk->sk_mark is set to the mark of the incoming skb.
> 
> I think the correct behaviour here is to to honour the
> ip_fwmark_reflect sysctl instead, and if it's enabled, make the synack
> mark be the same as the the incoming syn mark.
> 

Ok, so in the patch I sent then change this:

+       if (sock_net(sk)->ipv4.sysctl_tcp_fwmark_accept)
+               skb->mark = ireq->ir_mark;

to:

+       if (sock_net(sk)->ipv4.fwmark_reflect)
+               skb->mark = ireq->ir_mark;

correct?

cheers,
jamal
