From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 2/4] mlx4: xdp: Allow raising MTU up to one
 page minus eth and vlan hdrs
Date: Sun, 04 Dec 2016 16:52:54 -0800
Message-ID: <1480899174.18162.493.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1480721013-1047541-1-git-send-email-kafai@fb.com>
         <1480721013-1047541-3-git-send-email-kafai@fb.com>
         <1480725480.18162.394.camel@edumazet-glaptop3.roam.corp.google.com>
         <58421775.6090905@fb.com>
         <CALzJLG_82MNOyuq+y63tR2SDmKo3ZQA5XAgT1_r15B8_V19xKg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <ast@fb.com>, Martin KaFai Lau <kafai@fb.com>,
        Linux Netdev List <netdev@vger.kernel.org>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Miller <davem@davemloft.net>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>,
        Kernel Team <kernel-team@fb.com>
To: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:33436 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751070AbcLEAw6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 4 Dec 2016 19:52:58 -0500
Received: by mail-pg0-f67.google.com with SMTP id 3so14640762pgd.0
        for <netdev@vger.kernel.org>; Sun, 04 Dec 2016 16:52:58 -0800 (PST)
In-Reply-To: <CALzJLG_82MNOyuq+y63tR2SDmKo3ZQA5XAgT1_r15B8_V19xKg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-12-05 at 01:31 +0200, Saeed Mahameed wrote:

> Alexei, we should start considering PPC archs for XDP use cases,
> demanding page per packet on those archs is a little bit heavy
> requirement

Well, 'little' is an understatement ;)

Note that PPC had serious problems before  commit bd68a2a854ad5a85f0
("net: set SK_MEM_QUANTUM to 4096")

So I suspect one page per frame will likely be a huge problem
for hosts dealing with 10^5 or more TCP sockets.

Either skb->truesize is set to 64KB and TCP window must be really tiny,
or skb->truesize is set to ~2KB and OOM is waiting to happen.
