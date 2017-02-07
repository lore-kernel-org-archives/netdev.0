From: Tariq Toukan <ttoukan.linux@gmail.com>
Subject: Re: [PATCH net-next 9/9] mlx4: add page recycling in receive path
Date: Tue, 7 Feb 2017 18:20:12 +0200
Message-ID: <92a6e32b-6f0a-88a6-52d3-6ca352c26b22@gmail.com>
References: <20170207030240.31357-1-edumazet@google.com>
 <20170207030240.31357-10-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>,
        Martin KaFai Lau <kafai@fb.com>,
        Willem de Bruijn <willemb@google.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Alexei Starovoitov <ast@kernel.org>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: Eric Dumazet <edumazet@google.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:33163 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753894AbdBGQUP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2017 11:20:15 -0500
Received: by mail-wr0-f196.google.com with SMTP id i10so5993566wrb.0
        for <netdev@vger.kernel.org>; Tue, 07 Feb 2017 08:20:15 -0800 (PST)
In-Reply-To: <20170207030240.31357-10-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 07/02/2017 5:02 AM, Eric Dumazet wrote:
> Same technique than some Intel drivers, for arches where PAGE_SIZE = 4096
>
> In most cases, pages are reused because they were consumed
> before we could loop around the RX ring.
This might not be true when multiple streams are handled in the same ring.
As the process time in stack will be longer.
We will test this scenario as well.
>
> This brings back performance, and is even better,
> a single TCP flow reaches 30Gbit on my hosts.
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---
>   drivers/net/ethernet/mellanox/mlx4/en_rx.c   | 238 ++++++++-------------------
>   drivers/net/ethernet/mellanox/mlx4/mlx4_en.h |   1 -
>   2 files changed, 68 insertions(+), 171 deletions(-)
>
>
