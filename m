From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v2 1/2] Add a helper function to get socket
 cookie in eBPF
Date: Sun, 05 Feb 2017 19:30:24 -0800
Message-ID: <1486351824.7793.29.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1486347448-15393-1-git-send-email-chenbofeng.kernel@gmail.com>
         <1486347448-15393-2-git-send-email-chenbofeng.kernel@gmail.com>
         <CAKD1Yr0Jdj=KZ+MOs8V1WVYg_j3BkWQ6Ncmu9u4YYYu_pxS77A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Chenbo Feng <chenbofeng.kernel@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Willem de Bruijn <willemb@google.com>,
        Chenbo Feng <fengc@google.com>
To: Lorenzo Colitti <lorenzo@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:35098 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752051AbdBFDa1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 5 Feb 2017 22:30:27 -0500
Received: by mail-it0-f65.google.com with SMTP id 203so7378487ith.2
        for <netdev@vger.kernel.org>; Sun, 05 Feb 2017 19:30:26 -0800 (PST)
In-Reply-To: <CAKD1Yr0Jdj=KZ+MOs8V1WVYg_j3BkWQ6Ncmu9u4YYYu_pxS77A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-02-06 at 12:01 +0900, Lorenzo Colitti wrote:
> On Mon, Feb 6, 2017 at 11:17 AM, Chenbo Feng
> <chenbofeng.kernel@gmail.com> wrote:
> > +BPF_CALL_1(bpf_get_socket_cookie, struct sk_buff *, skb)
> > +{
> > +       return skb->sk ? sock_gen_cookie(skb->sk) : 0;
> > +}
> > +
> 
> Does this code need to increment the socket refcount, or call
> ACCESS_ONCE to get skb->sk? The socket filter codepath should be safe,
> but if this function is called in xt_ebpf, could it race with
> something that sets skb->sk to null?

I do not see how this could possibly happen.

READ_ONCE() would not prevent the 'old' sk from disappearing anyway.
