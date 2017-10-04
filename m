From: Wei Wang <weiwan@google.com>
Subject: Re: [PATCH net-next 1/2] tcp: uniform the set up of sockets after
 successful connection
Date: Tue, 3 Oct 2017 22:32:34 -0700
Message-ID: <CAEA6p_AtiNGGJ120_KScE1WrHnv_+v69HhM5xE_o-J_vN0B6Xg@mail.gmail.com>
References: <20171002170135.106183-1-tracywwnj@gmail.com> <20171003.212826.427984613713921100.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Yuchung Cheng <ycheng@google.com>,
        Neal Cardwell <ncardwell@google.com>,
        Eric Dumazet <edumazet@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f173.google.com ([209.85.217.173]:52411 "EHLO
        mail-ua0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751049AbdJDFcg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Oct 2017 01:32:36 -0400
Received: by mail-ua0-f173.google.com with SMTP id i35so3888708uah.9
        for <netdev@vger.kernel.org>; Tue, 03 Oct 2017 22:32:36 -0700 (PDT)
In-Reply-To: <20171003.212826.427984613713921100.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 3, 2017 at 9:28 PM, David Miller <davem@davemloft.net> wrote:
> From: Wei Wang <weiwan@google.com>
> Date: Mon,  2 Oct 2017 10:01:35 -0700
>
>> @@ -456,6 +456,19 @@ void tcp_init_sock(struct sock *sk)
>>  }
>>  EXPORT_SYMBOL(tcp_init_sock);
>>
>> +void tcp_init_transfer(struct sock *sk, int bpf_op)
>> +{
>> +     struct inet_connection_sock *icsk = inet_csk(sk);
>> +
>> +     tcp_mtup_init(sk);
>> +     icsk->icsk_af_ops->rebuild_header(sk);
>> +     tcp_init_metrics(sk);
>> +     tcp_call_bpf(sk, bpf_op);
>> +     tcp_init_congestion_control(sk);
>> +     tcp_init_buffer_space(sk);
>> +}
>> +EXPORT_SYMBOL(tcp_init_transfer);
>
> This symbol export is unnecessary, and if it were it should
> be EXPORT_SYMBOL_GPL().

I see. This function is only called in the TCP stack. Will remove
EXPORT_SYMBOL() in v2.
