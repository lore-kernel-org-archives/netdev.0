From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [PATCH v4 net-next 3/4] mlx4: xdp: Reserve headroom for receiving
 packet when XDP prog is active
Date: Thu, 8 Dec 2016 20:47:30 +0200
Message-ID: <CALzJLG9nKYhL=1G3g7UHvTruVn96O15WihySx41VEw7E_Xgq5w@mail.gmail.com>
References: <1481154794-2311034-1-git-send-email-kafai@fb.com> <1481154794-2311034-4-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>,
        Alexei Starovoitov <ast@fb.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Miller <davem@davemloft.net>,
        Jakub Kicinski <kubakici@wp.pl>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        John Fastabend <john.fastabend@gmail.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>,
        Kernel Team <kernel-team@fb.com>
To: Martin KaFai Lau <kafai@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f193.google.com ([209.85.210.193]:33133 "EHLO
        mail-wj0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752354AbcLHSrv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Dec 2016 13:47:51 -0500
Received: by mail-wj0-f193.google.com with SMTP id kp2so55761777wjc.0
        for <netdev@vger.kernel.org>; Thu, 08 Dec 2016 10:47:51 -0800 (PST)
In-Reply-To: <1481154794-2311034-4-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 8, 2016 at 1:53 AM, Martin KaFai Lau <kafai@fb.com> wrote:
> Reserve XDP_PACKET_HEADROOM for packet and enable bpf_xdp_adjust_head()
> support.  This patch only affects the code path when XDP is active.
>
> After testing, the tx_dropped counter is incremented if the xdp_prog sends
> more than wire MTU.
>

I guess this is the HW tx_dropped counter.  I suggest as a future
improvement to
drop in SW to save CPU and HW cycles on such packets.
Also those packets pages will be recycled immediately if dropped in
SW, one more extra point.

> Signed-off-by: Martin KaFai Lau <kafai@fb.com>

Acked-by: Saeed Mahameed <saeedm@mellanox.com>
