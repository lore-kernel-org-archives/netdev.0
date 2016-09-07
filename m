From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH RFC 08/11] net/mlx5e: XDP fast RX drop bpf programs support
Date: Wed, 7 Sep 2016 16:32:52 +0300
Message-ID: <CAJ3xEMhh=fu+mrCGAjv1PDdGn9GPLJv9MssMzwzvppoqZUY01A@mail.gmail.com>
References: <1473252152-11379-1-git-send-email-saeedm@mellanox.com> <1473252152-11379-9-git-send-email-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: iovisor-dev <iovisor-dev@lists.iovisor.org>,
        Linux Netdev List <netdev@vger.kernel.org>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Tom Herbert <tom@herbertland.com>,
        Martin KaFai Lau <kafai@fb.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Eric Dumazet <edumazet@google.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: Saeed Mahameed <saeedm@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>,
        Rana Shahout <ranas@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f49.google.com ([209.85.218.49]:34475 "EHLO
        mail-oi0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753974AbcIGNcy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Sep 2016 09:32:54 -0400
Received: by mail-oi0-f49.google.com with SMTP id m11so25551472oif.1
        for <netdev@vger.kernel.org>; Wed, 07 Sep 2016 06:32:53 -0700 (PDT)
In-Reply-To: <1473252152-11379-9-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 7, 2016 at 3:42 PM, Saeed Mahameed <saeedm@mellanox.com> wrote:

> Packet rate performance testing was done with pktgen 64B packets and on
> TX side and, TC drop action on RX side compared to XDP fast drop.
>
> CPU: Intel(R) Xeon(R) CPU E5-2680 v3 @ 2.50GHz
>
> Comparison is done between:
>         1. Baseline, Before this patch with TC drop action
>         2. This patch with TC drop action
>         3. This patch with XDP RX fast drop
>
> Streams    Baseline(TC drop)    TC drop    XDP fast Drop
> --------------------------------------------------------------
> 1           5.51Mpps            5.14Mpps     13.5Mpps
> 2           11.5Mpps            10.0Mpps     25.1Mpps
> 4           16.3Mpps            17.2Mpps     35.4Mpps
> 8           29.6Mpps            28.2Mpps     45.8Mpps*
> 16          34.0Mpps            30.1Mpps     45.8Mpps*

Rana, Guys, congrat!!

When you say X streams, does each stream mapped by RSS to different RX ring?
or we're on the same RX ring for all rows of the above table?

In the CX3 work, we had X sender "streams" that all mapped to the same RX ring,
I don't think we went beyond one RX ring.

Here, I guess you want to 1st get an initial max for N pktgen TX
threads all sending
the same stream so you land on single RX ring, and then move to M * N pktgen TX
threads to max that further.

I don't see how the current Linux stack would be able to happily drive 34M PPS
(== allocate SKB, etc, you know...) on a single CPU, Jesper?

Or.
