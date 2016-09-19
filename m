From: Eric Dumazet <edumazet@google.com>
Subject: Re: [PATCH v3 net-next 16/16] tcp_bbr: add BBR congestion control
Date: Mon, 19 Sep 2016 16:33:53 -0700
Message-ID: <CANn89i+u9JJf=DqPyOjwe639bdFYTNm0ny_POH2gmoaX4djLcA@mail.gmail.com>
References: <1474236233-28511-1-git-send-email-ncardwell@google.com>
 <1474236233-28511-17-git-send-email-ncardwell@google.com> <20160919135734.04ab5172@xeon-e3>
 <CANn89i+MpNPYn=ewi_LioNctNePCuity_UXw5ieU7HFfoZTsGA@mail.gmail.com> <20160919162848.2b916955@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Neal Cardwell <ncardwell@google.com>,
        David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>, Van Jacobson <vanj@google.com>,
        Yuchung Cheng <ycheng@google.com>,
        Nandita Dukkipati <nanditad@google.com>,
        Soheil Hassas Yeganeh <soheil@google.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yb0-f177.google.com ([209.85.213.177]:36271 "EHLO
        mail-yb0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751487AbcISXdz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2016 19:33:55 -0400
Received: by mail-yb0-f177.google.com with SMTP id u125so223308ybg.3
        for <netdev@vger.kernel.org>; Mon, 19 Sep 2016 16:33:54 -0700 (PDT)
In-Reply-To: <20160919162848.2b916955@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>
> It generates some slightly smaller code.
>         if (bbr->lt_rtt_cnt < bbr_lt_intvl_min_rtts)
> - 3e7:  0f b6 c0                movzbl %al,%eax
> - 3ea:  83 f8 03                cmp    $0x3,%eax
> - 3ed:  0f 86 d4 00 00 00       jbe    4c7 <bbr_lt_bw_sampling.isra.6+0x157>
> + 3e7:  3c 03                   cmp    $0x3,%al
> + 3e9:  0f 86 d1 00 00 00       jbe    4c0 <bbr_lt_bw_sampling.isra.6+0x150>
>
> And different code for abs
>                 /* Is new bw close to the lt_bw from the previous interval? */
>                 diff = abs(bw - bbr->lt_bw);
> - 47a:  44 89 e2                mov    %r12d,%edx
> - 47d:  29 c2                   sub    %eax,%edx
> - 47f:  89 d1                   mov    %edx,%ecx
> - 481:  89 d3                   mov    %edx,%ebx
> + 475:  44 89 e3                mov    %r12d,%ebx
> + 478:  29 c3                   sub    %eax,%ebx
> + 47a:  89 da                   mov    %ebx,%edx
> + 47c:  c1 fa 1f                sar    $0x1f,%edx
> + 47f:  31 d3                   xor    %edx,%ebx
> + 481:  29 d3                   sub    %edx,%ebx
>
> The biggest change is getting rid of the always true conditional.
>
...
>
> Overall, it really makes little difference. Actual file sizes come out the same.
> The idea is more to document what is variable
> and what is immutable in the algorithm.

SGTM, thanks Stephen !
