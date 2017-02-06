From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [PATCH net-next v2 1/2] Add a helper function to get socket
 cookie in eBPF
Date: Mon, 6 Feb 2017 12:01:47 +0900
Message-ID: <CAKD1Yr0Jdj=KZ+MOs8V1WVYg_j3BkWQ6Ncmu9u4YYYu_pxS77A@mail.gmail.com>
References: <1486347448-15393-1-git-send-email-chenbofeng.kernel@gmail.com> <1486347448-15393-2-git-send-email-chenbofeng.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Willem de Bruijn <willemb@google.com>,
        Chenbo Feng <fengc@google.com>
To: Chenbo Feng <chenbofeng.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f46.google.com ([209.85.213.46]:36366 "EHLO
        mail-vk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752878AbdBFDCN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 5 Feb 2017 22:02:13 -0500
Received: by mail-vk0-f46.google.com with SMTP id t8so47708641vke.3
        for <netdev@vger.kernel.org>; Sun, 05 Feb 2017 19:02:08 -0800 (PST)
In-Reply-To: <1486347448-15393-2-git-send-email-chenbofeng.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 6, 2017 at 11:17 AM, Chenbo Feng
<chenbofeng.kernel@gmail.com> wrote:
> +BPF_CALL_1(bpf_get_socket_cookie, struct sk_buff *, skb)
> +{
> +       return skb->sk ? sock_gen_cookie(skb->sk) : 0;
> +}
> +

Does this code need to increment the socket refcount, or call
ACCESS_ONCE to get skb->sk? The socket filter codepath should be safe,
but if this function is called in xt_ebpf, could it race with
something that sets skb->sk to null?
