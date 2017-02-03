From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 2/2] Add a eBPF helper function to retrieve
 socket uid
Date: Thu, 02 Feb 2017 16:31:01 -0800
Message-ID: <1486081861.21871.39.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170202205950.100334-1-chenbofeng.kernel@gmail.com>
         <20170202205950.100334-3-chenbofeng.kernel@gmail.com>
         <5893A587.6090000@iogearbox.net>
         <CAKD1Yr30K4Yi8U0bnTOq60rPW6aYY1Vb4xxmRgZdz319UmLmRw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        Chenbo Feng <chenbofeng.kernel@gmail.com>,
        "David S . Miller" <davem@davemloft.net>,
        Alexei Starovoitov <ast@fb.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Willem de Bruijn <willemb@google.com>,
        Chenbo Feng <fengc@google.com>
To: Lorenzo Colitti <lorenzo@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:33438 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751622AbdBCAbD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2017 19:31:03 -0500
Received: by mail-pf0-f195.google.com with SMTP id e4so285334pfg.0
        for <netdev@vger.kernel.org>; Thu, 02 Feb 2017 16:31:02 -0800 (PST)
In-Reply-To: <CAKD1Yr30K4Yi8U0bnTOq60rPW6aYY1Vb4xxmRgZdz319UmLmRw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-02-03 at 09:00 +0900, Lorenzo Colitti wrote:
> On Fri, Feb 3, 2017 at 6:32 AM, Daniel Borkmann <daniel@iogearbox.net> wrote:
> >> +       sk = skb->sk;
> >> +       kuid = sock_net_uid(dev_net(skb->dev), sk);
> >
> >
> > Don't you need to test for fullsock? Do you mean something like below?
> 
> It should be safe to call sock_net_uid on any type of socket
> (including NULL). sk_uid was added to struct sock in 86741ec25462
> ("net: core: Add a UID field to struct sock.")

But a request socket or a timewait socket do not have this field.

Daniel point is valid.
