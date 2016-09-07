From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH RFC 11/11] net/mlx5e: XDP TX xmit more
Date: Wed, 7 Sep 2016 06:44:18 -0700
Message-ID: <57D019B2.7070007@gmail.com>
References: <1473252152-11379-1-git-send-email-saeedm@mellanox.com>
 <1473252152-11379-12-git-send-email-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Tariq Toukan <tariqt@mellanox.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Tom Herbert <tom@herbertland.com>,
        Martin KaFai Lau <kafai@fb.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Eric Dumazet <edumazet@google.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: Saeed Mahameed <saeedm@mellanox.com>,
        iovisor-dev <iovisor-dev@lists.iovisor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:35571 "EHLO
        mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752277AbcIGNog (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Sep 2016 09:44:36 -0400
Received: by mail-pf0-f171.google.com with SMTP id w87so6938582pfk.2
        for <netdev@vger.kernel.org>; Wed, 07 Sep 2016 06:44:35 -0700 (PDT)
In-Reply-To: <1473252152-11379-12-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-09-07 05:42 AM, Saeed Mahameed wrote:
> Previously we rang XDP SQ doorbell on every forwarded XDP packet.
> 
> Here we introduce a xmit more like mechanism that will queue up more
> than one packet into SQ (up to RX napi budget) w/o notifying the hardware.
> 
> Once RX napi budget is consumed and we exit napi RX loop, we will
> flush (doorbell) all XDP looped packets in case there are such.
> 
> XDP forward packet rate:
> 
> Comparing XDP with and w/o xmit more (bulk transmit):
> 
> Streams     XDP TX       XDP TX (xmit more)
> ---------------------------------------------------
> 1           4.90Mpps      7.50Mpps
> 2           9.50Mpps      14.8Mpps
> 4           16.5Mpps      25.1Mpps
> 8           21.5Mpps      27.5Mpps*
> 16          24.1Mpps      27.5Mpps*
> 

Hi Saeed,

How many cores are you using with these numbers? Just a single
core? Or are streams being RSS'd across cores somehow.

> *It seems we hit a wall of 27.5Mpps, for 8 and 16 streams,
> we will be working on the analysis and will publish the conclusions
> later.
> 

Thanks,
John
