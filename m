From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [PATCH net-next 2/2] Add a eBPF helper function to retrieve
 socket uid
Date: Fri, 3 Feb 2017 09:00:26 +0900
Message-ID: <CAKD1Yr30K4Yi8U0bnTOq60rPW6aYY1Vb4xxmRgZdz319UmLmRw@mail.gmail.com>
References: <20170202205950.100334-1-chenbofeng.kernel@gmail.com>
 <20170202205950.100334-3-chenbofeng.kernel@gmail.com> <5893A587.6090000@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Chenbo Feng <chenbofeng.kernel@gmail.com>,
        "David S . Miller" <davem@davemloft.net>,
        Alexei Starovoitov <ast@fb.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Willem de Bruijn <willemb@google.com>,
        Chenbo Feng <fengc@google.com>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f171.google.com ([209.85.217.171]:34029 "EHLO
        mail-ua0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751595AbdBCAAr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2017 19:00:47 -0500
Received: by mail-ua0-f171.google.com with SMTP id 35so2818121uak.1
        for <netdev@vger.kernel.org>; Thu, 02 Feb 2017 16:00:47 -0800 (PST)
In-Reply-To: <5893A587.6090000@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 3, 2017 at 6:32 AM, Daniel Borkmann <daniel@iogearbox.net> wrote:
>> +       sk = skb->sk;
>> +       kuid = sock_net_uid(dev_net(skb->dev), sk);
>
>
> Don't you need to test for fullsock? Do you mean something like below?

It should be safe to call sock_net_uid on any type of socket
(including NULL). sk_uid was added to struct sock in 86741ec25462
("net: core: Add a UID field to struct sock.")
