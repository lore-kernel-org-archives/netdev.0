From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH RFC 08/11] net/mlx5e: XDP fast RX drop bpf programs
 support
Date: Thu, 8 Sep 2016 06:58:46 -0400
Message-ID: <398c948e-9c7c-ffe6-0814-7be70c65d0b6@mojatatu.com>
References: <1473252152-11379-1-git-send-email-saeedm@mellanox.com>
 <1473252152-11379-9-git-send-email-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Tariq Toukan <tariqt@mellanox.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Tom Herbert <tom@herbertland.com>,
        Martin KaFai Lau <kafai@fb.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Eric Dumazet <edumazet@google.com>,
        Rana Shahout <ranas@mellanox.com>
To: Saeed Mahameed <saeedm@mellanox.com>,
        iovisor-dev <iovisor-dev@lists.iovisor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f48.google.com ([209.85.214.48]:36231 "EHLO
        mail-it0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S941391AbcIHK6t (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Sep 2016 06:58:49 -0400
Received: by mail-it0-f48.google.com with SMTP id i184so248894236itf.1
        for <netdev@vger.kernel.org>; Thu, 08 Sep 2016 03:58:48 -0700 (PDT)
In-Reply-To: <1473252152-11379-9-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 16-09-07 08:42 AM, Saeed Mahameed wrote:

> Comparison is done between:
> 	1. Baseline, Before this patch with TC drop action
> 	2. This patch with TC drop action
> 	3. This patch with XDP RX fast drop
>
> Streams    Baseline(TC drop)    TC drop    XDP fast Drop
> --------------------------------------------------------------
> 1           5.51Mpps            5.14Mpps     13.5Mpps
> 2           11.5Mpps            10.0Mpps     25.1Mpps
> 4           16.3Mpps            17.2Mpps     35.4Mpps
> 8           29.6Mpps            28.2Mpps     45.8Mpps*
> 16          34.0Mpps            30.1Mpps     45.8Mpps*
>
> It seems that there is around ~5% degradation between Baseline
> and this patch with single stream when comparing packet rate with TC drop,
> it might be related to XDP code overhead or new cache misses added by
> XDP code.


I would suspect this degradation would affect every other packet that
has no interest in XDP.
if you were trying to test forwarding, adding a tc action to
accept and count packets will be sufficient. Since you are not:

Try to baseline sending the wrong destination MAC  address (i.e one
not understood by host). The kernel will eventually drop it
somewhere pre-IP processing time (and you can see difference with
XDP compiled in).

Slightly tangent question: Would it be fair to assume that this
hardware can drop at wire rate if you instead used an offloaded
tc rule?

cheers,
jamal
