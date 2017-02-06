From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [PATCH net-next 2/2] Add a eBPF helper function to retrieve
 socket uid
Date: Mon, 6 Feb 2017 12:25:33 +0900
Message-ID: <CAKD1Yr3SyKQ23P8F++cpS129kw5tUssCpPJyh8R+JTujNw0Nqg@mail.gmail.com>
References: <20170202205950.100334-1-chenbofeng.kernel@gmail.com>
 <20170202205950.100334-3-chenbofeng.kernel@gmail.com> <5893A587.6090000@iogearbox.net>
 <CAKD1Yr30K4Yi8U0bnTOq60rPW6aYY1Vb4xxmRgZdz319UmLmRw@mail.gmail.com>
 <1486081861.21871.39.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAKD1Yr1tPP-7ic4nreqzKk6Gb+ZgyKo8yqw-KP=w7oqABkiZQA@mail.gmail.com> <1486086708.21871.48.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        Chenbo Feng <chenbofeng.kernel@gmail.com>,
        "David S . Miller" <davem@davemloft.net>,
        Alexei Starovoitov <ast@fb.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Willem de Bruijn <willemb@google.com>,
        Chenbo Feng <fengc@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f46.google.com ([209.85.213.46]:33537 "EHLO
        mail-vk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753173AbdBFDZ4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 5 Feb 2017 22:25:56 -0500
Received: by mail-vk0-f46.google.com with SMTP id k127so47937456vke.0
        for <netdev@vger.kernel.org>; Sun, 05 Feb 2017 19:25:56 -0800 (PST)
In-Reply-To: <1486086708.21871.48.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 3, 2017 at 10:51 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> if (sk) {
>     sk = sk_to_full_sk(sk);
>     if (sk_fullsock(sk))
>         return sk->sk_uid;
> }

Sure, though sk_to_full_sk is in inet_sock.h so I have to move some
core around. Options I see:

1. Move sk_to_full_sk from inet_sock.h to sock.h.
2. Move sock_net_uid to inet_sock.h.
3. Move sock_net_uid to sock.c and EXPORT_SYMBOL_GPL it.

Thoughts? #1 seems reasonable, since sk_fullsock is already in sock.h.
#2 would mean that we can't call sock_net_uid from non-inet code.
Currently the only code that accesses sk->sk_uid is inet code, but in
the future perhaps some of the code around the tree that calls
sock_i_uid could be migrated to use at sk->sk_uid instead.
