From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v2 2/2] Add a eBPF helper function to retrieve
 socket uid
Date: Sun, 05 Feb 2017 19:02:01 -0800
Message-ID: <1486350121.7793.27.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1486347448-15393-1-git-send-email-chenbofeng.kernel@gmail.com>
         <1486347448-15393-3-git-send-email-chenbofeng.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Lorenzo Colitti <lorenzo@google.com>,
        Willem de Bruijn <willemb@google.com>,
        Chenbo Feng <fengc@google.com>
To: Chenbo Feng <chenbofeng.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:33105 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751907AbdBFDCE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 5 Feb 2017 22:02:04 -0500
Received: by mail-it0-f65.google.com with SMTP id e137so7299629itc.0
        for <netdev@vger.kernel.org>; Sun, 05 Feb 2017 19:02:04 -0800 (PST)
In-Reply-To: <1486347448-15393-3-git-send-email-chenbofeng.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2017-02-05 at 18:17 -0800, Chenbo Feng wrote:
> From: Chenbo Feng <fengc@google.com>
> 
> Returns the owner uid of the socket inside a sk_buff. This is useful to
> perform per-UID accounting of network traffic or per-UID packet
> filtering.
> 
> Signed-off-by: Chenbo Feng <chenbofeng.kernel@gmail.com>
> ---
> +BPF_CALL_1(bpf_get_socket_uid, struct sk_buff *, skb)
> +{
> +	struct sock *sk = skb->sk;
> +	kuid_t kuid = sock_net_uid(net, sk && sk_fullsock(sk) ?
> +				   sk : NULL);
> +	return (u32)kuid.val;
> +}
> +

Have you considered to use sk_to_full_sk() ?

struct sock *sk = sk_to_full_sk(skb->sk);
kuid_t kuid = sock_net_uid(net, sk);
