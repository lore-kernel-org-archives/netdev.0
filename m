From: Eric Dumazet <edumazet@google.com>
Subject: Re: [PATCH v2 net-next 07/16] tcp: track data delivery rate for a TCP connection
Date: Sat, 17 Sep 2016 12:09:08 -0700
Message-ID: <CANn89iKmEP1q9dRdOJWwULyCFXTSOYJH+WGjBaHgHMMycdZgDg@mail.gmail.com>
References: <1474133749-12895-8-git-send-email-ncardwell@google.com> <201609180342.qLM70Old%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Neal Cardwell <ncardwell@google.com>, kbuild-all@01.org,
        David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Yuchung Cheng <ycheng@google.com>,
        Van Jacobson <vanj@google.com>,
        Nandita Dukkipati <nanditad@google.com>,
        Soheil Hassas Yeganeh <soheil@google.com>
To: kbuild test robot <lkp@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yb0-f178.google.com ([209.85.213.178]:33102 "EHLO
        mail-yb0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754166AbcIQTJL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 17 Sep 2016 15:09:11 -0400
Received: by mail-yb0-f178.google.com with SMTP id i66so63668824yba.0
        for <netdev@vger.kernel.org>; Sat, 17 Sep 2016 12:09:10 -0700 (PDT)
In-Reply-To: <201609180342.qLM70Old%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Sep 17, 2016 at 12:04 PM, kbuild test robot <lkp@intel.com> wrote:
> Hi Yuchung,
>
> [auto build test ERROR on net-next/master]
>
> url:    https://github.com/0day-ci/linux/commits/Neal-Cardwell/tcp-BBR-congestion-control-algorithm/20160918-014058
> config: x86_64-randconfig-s2-09180225 (attached as .config)
> compiler: gcc-4.4 (Debian 4.4.7-8) 4.4.7
> reproduce:
>         # save the attached .config to linux build tree
>         make ARCH=x86_64
>
> All error/warnings (new ones prefixed by >>):
>
>    net/ipv4/tcp_input.c: In function 'tcp_ack':
>>> net/ipv4/tcp_input.c:3559: error: unknown field 'v64' specified in initializer
>>> net/ipv4/tcp_input.c:3559: warning: missing braces around initializer
>    net/ipv4/tcp_input.c:3559: warning: (near initialization for 'rs.prior_mstamp.<anonymous>')
>
> vim +/v64 +3559 net/ipv4/tcp_input.c
>
>   3553  /* This routine deals with incoming acks, but not outgoing ones. */
>   3554  static int tcp_ack(struct sock *sk, const struct sk_buff *skb, int flag)
>   3555  {
>   3556          struct inet_connection_sock *icsk = inet_csk(sk);
>   3557          struct tcp_sock *tp = tcp_sk(sk);
>   3558          struct tcp_sacktag_state sack_state;
>> 3559          struct rate_sample rs = { .prior_mstamp.v64 = 0, .prior_delivered = 0 };
>

Arg, silly compilers out there.

We can omit prior_mstamp , as the compiler will zero fields anyway

struct rate_sample rs = { .prior_delivered = 0 };
