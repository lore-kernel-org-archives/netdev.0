From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH v3 net-next] tcp: Change txhash on every SYN and RTO retransmit
Date: Tue, 27 Sep 2016 21:28:11 -0400
Message-ID: <CADVnQykozyJ3nnHz956aXnT9c+cEqUmf0HMqSHjbKQXWiMoSTA@mail.gmail.com>
References: <20160927233123.2447232-1-brakmo@fb.com> <CAK6E8=dDXd9PFA=AojMOsTOXTm_KkczB2_4G3vPuQLC2Ni5QsQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Lawrence Brakmo <brakmo@fb.com>, netdev <netdev@vger.kernel.org>,
        Kernel Team <kernel-team@fb.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f54.google.com ([209.85.218.54]:32800 "EHLO
        mail-oi0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755074AbcI1B2n (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2016 21:28:43 -0400
Received: by mail-oi0-f54.google.com with SMTP id r126so36244360oib.0
        for <netdev@vger.kernel.org>; Tue, 27 Sep 2016 18:28:43 -0700 (PDT)
In-Reply-To: <CAK6E8=dDXd9PFA=AojMOsTOXTm_KkczB2_4G3vPuQLC2Ni5QsQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 27, 2016 at 8:18 PM, Yuchung Cheng <ycheng@google.com> wrote:
> On Tue, Sep 27, 2016 at 4:31 PM, Lawrence Brakmo <brakmo@fb.com> wrote:
>> @@ -213,6 +215,8 @@ static int tcp_write_timeout(struct sock *sk)
>>                         tcp_mtu_probing(icsk, sk);
>>
>>                         dst_negative_advice(sk);
>> +               } else if (prandom_u32_max(100) < sysctl_tcp_rto_txhash_prob) {
> The sysctl is not really needed but that's just my opinion.

I agree that it sounds nice to simplify by not having a sysctl for
this and always calling sk_rethink_txhash() here.

neal
