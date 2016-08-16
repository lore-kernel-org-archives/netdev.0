From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: Fw: Linux tcp_xmit_retransmit_queue use after free on 4.8-rc1 / master]
Date: Tue, 16 Aug 2016 13:32:58 -0700
Message-ID: <CAM_iQpW46DkWU2COW6tXUj3W==WQVkHT--qW8Hfus5ZiiKtYvA@mail.gmail.com>
References: <20160816104551.GA28052@kroah.com> <1471361940.4943.4.camel@edumazet-glaptop3.roam.corp.google.com>
 <1471372748.4943.7.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAM_iQpXV-jV0FsAzxt4JYrc6d5LCCLt-5_0uMvM49sV8-+SDDQ@mail.gmail.com> <1471379279.4943.14.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Greg KH <gregkh@linuxfoundation.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Marco Grassi <marco.gra@gmail.com>,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:34411 "EHLO
	mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753868AbcHPUdT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Aug 2016 16:33:19 -0400
Received: by mail-it0-f67.google.com with SMTP id e63so3741003ith.1
        for <netdev@vger.kernel.org>; Tue, 16 Aug 2016 13:33:19 -0700 (PDT)
In-Reply-To: <1471379279.4943.14.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 16, 2016 at 1:27 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> And tcp_add_write_queue_tail() looks like :
>
>
> static inline void tcp_add_write_queue_tail(struct sock *sk, struct sk_buff *skb)
> {
>         __tcp_add_write_queue_tail(sk, skb);
>
>         /* Queue it, remembering where we must start sending. */
>         if (sk->sk_send_head == NULL) {
>                 sk->sk_send_head = skb;
>
>                 if (tcp_sk(sk)->highest_sack == NULL)
>                         tcp_sk(sk)->highest_sack = skb;
>         }
> }
>

Ah, I never looked into tcp_add_write_queue_tail()...

So this bug seems exist after commit 6859d49475d4f32abe640372117e4b...
