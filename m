From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next 7/8] net/mlx5e: XDP TX forwarding support
Date: Tue, 20 Sep 2016 09:00:55 -0700
Message-ID: <20160920160054.GA99429@ast-mbp.thefacebook.com>
References: <1474293539-2595-1-git-send-email-tariqt@mellanox.com>
 <1474293539-2595-8-git-send-email-tariqt@mellanox.com>
 <20160920102943.24732097@brouer.com>
 <20160920133300.144037fd@redhat.com>
 <96b40925-0e8e-0230-0701-96c11d6921a1@gmail.com>
 <20160920154036.GA98644@ast-mbp.thefacebook.com>
 <CALx6S34YBsmSJr7z2wGsu1VvLkjoqTN+Q8JJ0j-H_DehMJzQ5g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tariq Toukan <ttoukan.linux@gmail.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Tariq Toukan <tariqt@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Eran Ben Elisha <eranbe@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Rana Shahout <ranas@mellanox.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:35393 "EHLO
        mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751643AbcITQBB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 12:01:01 -0400
Received: by mail-pf0-f169.google.com with SMTP id z123so8796323pfz.2
        for <netdev@vger.kernel.org>; Tue, 20 Sep 2016 09:01:01 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CALx6S34YBsmSJr7z2wGsu1VvLkjoqTN+Q8JJ0j-H_DehMJzQ5g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 20, 2016 at 08:51:05AM -0700, Tom Herbert wrote:
> On Tue, Sep 20, 2016 at 8:40 AM, Alexei Starovoitov
> <alexei.starovoitov@gmail.com> wrote:
> > On Tue, Sep 20, 2016 at 03:53:10PM +0300, Tariq Toukan wrote:
> >> >>>+  case XDP_ABORTED:
> >> >>It is not clearly defined, but I believe XDP_ABORTED should also result
> >> >>in a warning (calling bpf_warn_invalid_xdp_action(act)).
> >> I'll add this.
> >
> > Certainly NOT.
> > XDP_ABORTED is an exception case when program does divide by zero.
> > It should NOT do bpf_warn. It must drop the packet.
> > We discussed it several months ago.
> > See mlx4/en_rx.c for canonical implementation.
> >
> It should at least bump a counter so that the user knows that aborts
> are happening.

yes the driver can add another counter, but it's not mandated by xdp side.
Meaning it's up to the driver to have counters and their way of
reporting thems (so far all drivers do it via ethtool).
We don't define any counters via XDP api, since they cannot be defined
in a common way across different nics and hw, and we already have ethtool
which is good enough. Especially in this case 'aborted' counter is
only for debugging. The program should not have 'divide by zero' when
it's written correctly.
