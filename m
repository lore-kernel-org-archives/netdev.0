From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next 7/8] net/mlx5e: XDP TX forwarding support
Date: Tue, 20 Sep 2016 08:51:05 -0700
Message-ID: <CALx6S34YBsmSJr7z2wGsu1VvLkjoqTN+Q8JJ0j-H_DehMJzQ5g@mail.gmail.com>
References: <1474293539-2595-1-git-send-email-tariqt@mellanox.com>
 <1474293539-2595-8-git-send-email-tariqt@mellanox.com> <20160920102943.24732097@brouer.com>
 <20160920133300.144037fd@redhat.com> <96b40925-0e8e-0230-0701-96c11d6921a1@gmail.com>
 <20160920154036.GA98644@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Tariq Toukan <ttoukan.linux@gmail.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Tariq Toukan <tariqt@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Eran Ben Elisha <eranbe@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Rana Shahout <ranas@mellanox.com>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f175.google.com ([209.85.220.175]:36665 "EHLO
        mail-qk0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932484AbcITPvH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 11:51:07 -0400
Received: by mail-qk0-f175.google.com with SMTP id z190so19238308qkc.3
        for <netdev@vger.kernel.org>; Tue, 20 Sep 2016 08:51:06 -0700 (PDT)
In-Reply-To: <20160920154036.GA98644@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 20, 2016 at 8:40 AM, Alexei Starovoitov
<alexei.starovoitov@gmail.com> wrote:
> On Tue, Sep 20, 2016 at 03:53:10PM +0300, Tariq Toukan wrote:
>> >>>+  case XDP_ABORTED:
>> >>It is not clearly defined, but I believe XDP_ABORTED should also result
>> >>in a warning (calling bpf_warn_invalid_xdp_action(act)).
>> I'll add this.
>
> Certainly NOT.
> XDP_ABORTED is an exception case when program does divide by zero.
> It should NOT do bpf_warn. It must drop the packet.
> We discussed it several months ago.
> See mlx4/en_rx.c for canonical implementation.
>
It should at least bump a counter so that the user knows that aborts
are happening.
