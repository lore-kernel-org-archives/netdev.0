From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [PATCH net-next v6 2/3] Add a eBPF helper function to retrieve
 socket uid
Date: Tue, 21 Mar 2017 16:00:25 +0900
Message-ID: <CAKD1Yr3j0M=hCXmvjNf_EQhejMVinSeR4nj5p910iY8G4i1BfA@mail.gmail.com>
References: <1490069337-14076-1-git-send-email-chenbofeng.kernel@gmail.com> <1490069337-14076-3-git-send-email-chenbofeng.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Willem de Bruijn <willemb@google.com>,
        Chenbo Feng <fengc@google.com>
To: Chenbo Feng <chenbofeng.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f48.google.com ([209.85.213.48]:32808 "EHLO
        mail-vk0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756461AbdCUHAs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Mar 2017 03:00:48 -0400
Received: by mail-vk0-f48.google.com with SMTP id d188so84985799vka.0
        for <netdev@vger.kernel.org>; Tue, 21 Mar 2017 00:00:47 -0700 (PDT)
In-Reply-To: <1490069337-14076-3-git-send-email-chenbofeng.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 21, 2017 at 1:08 PM, Chenbo Feng
<chenbofeng.kernel@gmail.com> wrote:
> +       if (!sk || !sk_fullsock(sk))
> +               return overflowuid;
> +       kuid = sock_net_uid(sock_net(sk), sk);
> +       return from_kuid_munged(current_user_ns(), kuid);

Is current_user_ns() correct in all the contexts you'll want to run
this code from? For packets sent by userspace applications it's likely
to be correct, but what about received packets, and packets processed
by the xt_ebpf module?
