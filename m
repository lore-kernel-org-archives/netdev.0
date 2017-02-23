From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH net-next v3 2/3] Add a eBPF helper function to retrieve
 socket uid
Date: Thu, 23 Feb 2017 12:03:58 -0500
Message-ID: <CAF=yD-J2Z+KqxpnkfZkNUYDR4do8wEBSHims2TTMGgpdwm9SLg@mail.gmail.com>
References: <1487824932-5105-1-git-send-email-chenbofeng.kernel@gmail.com> <1487824932-5105-3-git-send-email-chenbofeng.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>,
        Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Lorenzo Colitti <lorenzo@google.com>,
        Willem de Bruijn <willemb@google.com>,
        Chenbo Feng <fengc@google.com>
To: Chenbo Feng <chenbofeng.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:36001 "EHLO
        mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751099AbdBWROT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 23 Feb 2017 12:14:19 -0500
Received: by mail-wm0-f47.google.com with SMTP id v77so35622895wmv.1
        for <netdev@vger.kernel.org>; Thu, 23 Feb 2017 09:13:21 -0800 (PST)
In-Reply-To: <1487824932-5105-3-git-send-email-chenbofeng.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +BPF_CALL_1(bpf_get_socket_uid, struct sk_buff *, skb)
> +{
> +       struct sock *sk = sk_to_full_sk(skb->sk);
> +       kuid_t kuid = sock_net_uid(dev_net(skb->dev), sk);

dev_net cannot handle a NULL skb->dev
