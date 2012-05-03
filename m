From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH v4 2/3] tcp: early retransmit
Date: Wed, 2 May 2012 20:14:31 -0400
Message-ID: <CADVnQy=Sq8=vboHjN5D1VFftyGWQO=3edkTx4Vy6pvW-fezmSQ@mail.gmail.com>
References: <1336001404-21879-1-git-send-email-ycheng@google.com>
	<1336001404-21879-2-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, ilpo.jarvinen@helsinki.fi,
	nanditad@google.com, netdev@vger.kernel.org
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:38748 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752539Ab2ECAOc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 May 2012 20:14:32 -0400
Received: by yhmm54 with SMTP id m54so1319223yhm.19
        for <netdev@vger.kernel.org>; Wed, 02 May 2012 17:14:31 -0700 (PDT)
In-Reply-To: <1336001404-21879-2-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 2, 2012 at 7:30 PM, Yuchung Cheng <ycheng@google.com> wrote=
:
> This patch implements RFC 5827 early retransmit (ER) for TCP.
> It reduces DUPACK threshold (dupthresh) if outstanding packets are
> less than 4 to recover losses by fast recovery instead of timeout.
>
> While the algorithm is simple, small but frequent network reordering
> makes this feature dangerous: the connection repeatedly enter
> false recovery and degrade performance. Therefore we implement
> a mitigation suggested in the appendix of the RFC that delays
> entering fast recovery by a small interval, i.e., RTT/4. Currently
> ER is conservative and is disabled for the rest of the connection
> after the first reordering event. A large scale web server
> experiment on the performance impact of ER is summarized in
> section 6 of the paper "Proportional Rate Reduction for TCP=94,
> IMC 2011. http://conferences.sigcomm.org/imc/2011/docs/p155.pdf
>
> Note that Linux has a similar feature called THIN_DUPACK. The
> differences are THIN_DUPACK do not mitigate reorderings and is only
> used after slow start. Currently ER is disabled if THIN_DUPACK is
> enabled. I would be happy to merge THIN_DUPACK feature with ER if
> people think it's a good idea.
>
> ER is enabled by sysctl_tcp_early_retrans:
> =A00: Disables ER
>
> =A01: Reduce dupthresh to packets_out - 1 when outstanding packets < =
4.
>
> =A02: (Default) reduce dupthresh like mode 1. In addition, delay
> =A0 =A0 entering fast recovery by RTT/4.
>
> Note: mode 2 is implemented in the third part of this patch series.
>
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> ---
> ChangeLog in v2:
> =A0- swapped part1 and part2
> ChangeLog in v3:
> =A0- trivial text fixes in documentation.
> ChangeLog in v4:
> =A0- disables ER if any reordering. shuffle early retransmit vars in =
tcp_sock.

Acked-by: Neal Cardwell <ncardwell@google.com>

neal
