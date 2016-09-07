From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH RFC 11/11] net/mlx5e: XDP TX xmit more
Date: Wed, 07 Sep 2016 07:41:42 -0700
Message-ID: <1473259302.10725.31.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1473252152-11379-1-git-send-email-saeedm@mellanox.com>
         <1473252152-11379-12-git-send-email-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: iovisor-dev <iovisor-dev@lists.iovisor.org>,
        netdev@vger.kernel.org, Tariq Toukan <tariqt@mellanox.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Tom Herbert <tom@herbertland.com>,
        Martin KaFai Lau <kafai@fb.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Eric Dumazet <edumazet@google.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: Saeed Mahameed <saeedm@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:35295 "EHLO
        mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751952AbcIGOlo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Sep 2016 10:41:44 -0400
Received: by mail-pa0-f48.google.com with SMTP id b2so7035932pat.2
        for <netdev@vger.kernel.org>; Wed, 07 Sep 2016 07:41:44 -0700 (PDT)
In-Reply-To: <1473252152-11379-12-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-09-07 at 15:42 +0300, Saeed Mahameed wrote:
> Previously we rang XDP SQ doorbell on every forwarded XDP packet.
> 
> Here we introduce a xmit more like mechanism that will queue up more
> than one packet into SQ (up to RX napi budget) w/o notifying the hardware.
> 
> Once RX napi budget is consumed and we exit napi RX loop, we will
> flush (doorbell) all XDP looped packets in case there are such.

Why is this idea depends on XDP ?

It looks like we could apply it to any driver having one IRQ servicing
one RX and one TX, without XDP being involved.
