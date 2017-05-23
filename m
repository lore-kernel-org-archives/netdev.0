From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [net PATCH] mlx5: fix bug reading rss_hash_type from CQE
Date: Tue, 23 May 2017 13:58:44 +0300
Message-ID: <CALzJLG9sAw3_-jL9R3=g6pZ517NMVRrFFya0E+NE5jUMH_uu8w@mail.gmail.com>
References: <149547678696.10455.14428063974882319686.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Saeed Mahameed <saeedm@mellanox.com>,
        Daniel Borkmann <borkmann@iogearbox.net>,
        Linux Netdev List <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f196.google.com ([209.85.220.196]:33055 "EHLO
        mail-qk0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1760909AbdEWK7F (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 May 2017 06:59:05 -0400
Received: by mail-qk0-f196.google.com with SMTP id o85so22338262qkh.0
        for <netdev@vger.kernel.org>; Tue, 23 May 2017 03:59:05 -0700 (PDT)
In-Reply-To: <149547678696.10455.14428063974882319686.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 22, 2017 at 9:13 PM, Jesper Dangaard Brouer
<brouer@redhat.com> wrote:
> Masks for extracting part of the Completion Queue Entry (CQE)
> field rss_hash_type was swapped, namely CQE_RSS_HTYPE_IP and
> CQE_RSS_HTYPE_L4.
>
> The bug resulted in setting skb->l4_hash, even-though the
> rss_hash_type indicated that hash was NOT computed over the
> L4 (UDP or TCP) part of the packet.
>
> Added comments from the datasheet, to make it more clear what
> these masks are selecting.
>
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
> ---
>  include/linux/mlx5/device.h |   10 ++++++++--
>  1 file changed, 8 insertions(+), 2 deletions(-)
>
> diff --git a/include/linux/mlx5/device.h b/include/linux/mlx5/device.h
> index dd9a263ed368..a940ec6a046c 100644
> --- a/include/linux/mlx5/device.h
> +++ b/include/linux/mlx5/device.h
> @@ -787,8 +787,14 @@ enum {
>  };
>
>  enum {
> -       CQE_RSS_HTYPE_IP        = 0x3 << 6,
> -       CQE_RSS_HTYPE_L4        = 0x3 << 2,
> +       CQE_RSS_HTYPE_IP        = 0x3 << 2,
> +       /* cqe->rss_hash_type[3:2] - IP destination selected for hash
> +        * (00 = none,  01 = IPv4, 10 = IPv6, 11 = Reserved)
> +        */
> +       CQE_RSS_HTYPE_L4        = 0x3 << 6,
> +       /* cqe->rss_hash_type[7:6] - L4 destination selected for hash
> +        * (00 = none, 01 = TCP. 10 = UDP, 11 = IPSEC.SPI
> +        */
>  };
>

Acked-by: Saeed Mahameed <saeedm@mellanox.com>

Nice catch Jesper !!

Can I ask how did you find the hash was wrong ? any
counters/indicators we can look for in internal testing ?

>  enum {
>
