From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next] pktgen: Use seq_puts() where seq_printf() is not needed
Date: Fri, 16 May 2014 08:02:39 -0700
Message-ID: <CAADnVQJfmDqeayQUaL7KZLjnQQu8QTiYKJ5wkrMxWdgvKNx8ug@mail.gmail.com>
References: <090215cd09d88cd79c4e37ff2cc9f7da58205f76.1400237005.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f50.google.com ([209.85.192.50]:37280 "EHLO
	mail-qg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757488AbaEPPCk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2014 11:02:40 -0400
Received: by mail-qg0-f50.google.com with SMTP id z60so4424721qgd.9
        for <netdev@vger.kernel.org>; Fri, 16 May 2014 08:02:39 -0700 (PDT)
In-Reply-To: <090215cd09d88cd79c4e37ff2cc9f7da58205f76.1400237005.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 16, 2014 at 3:53 AM, Thomas Graf <tgraf@suug.ch> wrote:
> Signed-off-by: Thomas Graf <tgraf@suug.ch>
> ---
>  net/core/pktgen.c | 50 +++++++++++++++++++++++++-------------------------
>  1 file changed, 25 insertions(+), 25 deletions(-)
>
> diff --git a/net/core/pktgen.c b/net/core/pktgen.c
> index 8278df8..038c46f 100644
> --- a/net/core/pktgen.c
> +++ b/net/core/pktgen.c
> @@ -574,7 +574,7 @@ static int pktgen_if_show(struct seq_file *seq, void *v)
>                    is_zero_ether_addr(pkt_dev->src_mac) ?
>                              pkt_dev->odev->dev_addr : pkt_dev->src_mac);
>
> -       seq_printf(seq, "dst_mac: ");
> +       seq_puts(seq, "dst_mac: ");

tough luck of kernel developers... ;)
Normal printf() GCC optimizes into puts() automatically.

>         seq_printf(seq, "%pM\n", pkt_dev->dst_mac);
>
>         seq_printf(seq,
> @@ -589,7 +589,7 @@ static int pktgen_if_show(struct seq_file *seq, void *v)
>
>         if (pkt_dev->nr_labels) {
>                 unsigned int i;
> -               seq_printf(seq, "     mpls: ");
> +               seq_puts(seq, "     mpls: ");
>                 for (i = 0; i < pkt_dev->nr_labels; i++)
>                         seq_printf(seq, "%08x%s", ntohl(pkt_dev->labels[i]),
>                                    i == pkt_dev->nr_labels-1 ? "\n" : ", ");
> @@ -614,67 +614,67 @@ static int pktgen_if_show(struct seq_file *seq, void *v)
>         if (pkt_dev->node >= 0)
>                 seq_printf(seq, "     node: %d\n", pkt_dev->node);
>
> -       seq_printf(seq, "     Flags: ");
> +       seq_puts(seq, "     Flags: ");
>
>         if (pkt_dev->flags & F_IPV6)
> -               seq_printf(seq, "IPV6  ");
> +               seq_puts(seq, "IPV6  ");
>
>         if (pkt_dev->flags & F_IPSRC_RND)
> -               seq_printf(seq, "IPSRC_RND  ");
> +               seq_puts(seq, "IPSRC_RND  ");
>
>         if (pkt_dev->flags & F_IPDST_RND)
> -               seq_printf(seq, "IPDST_RND  ");
> +               seq_puts(seq, "IPDST_RND  ");
>
>         if (pkt_dev->flags & F_TXSIZE_RND)
> -               seq_printf(seq, "TXSIZE_RND  ");
> +               seq_puts(seq, "TXSIZE_RND  ");
>
>         if (pkt_dev->flags & F_UDPSRC_RND)
> -               seq_printf(seq, "UDPSRC_RND  ");
> +               seq_puts(seq, "UDPSRC_RND  ");
>
>         if (pkt_dev->flags & F_UDPDST_RND)
> -               seq_printf(seq, "UDPDST_RND  ");
> +               seq_puts(seq, "UDPDST_RND  ");
>
>         if (pkt_dev->flags & F_UDPCSUM)
> -               seq_printf(seq, "UDPCSUM  ");
> +               seq_puts(seq, "UDPCSUM  ");
>
>         if (pkt_dev->flags & F_MPLS_RND)
> -               seq_printf(seq,  "MPLS_RND  ");
> +               seq_puts(seq,  "MPLS_RND  ");
>
>         if (pkt_dev->flags & F_QUEUE_MAP_RND)
> -               seq_printf(seq,  "QUEUE_MAP_RND  ");
> +               seq_puts(seq,  "QUEUE_MAP_RND  ");
>
>         if (pkt_dev->flags & F_QUEUE_MAP_CPU)
> -               seq_printf(seq,  "QUEUE_MAP_CPU  ");
> +               seq_puts(seq,  "QUEUE_MAP_CPU  ");
>
>         if (pkt_dev->cflows) {
>                 if (pkt_dev->flags & F_FLOW_SEQ)
> -                       seq_printf(seq,  "FLOW_SEQ  "); /*in sequence flows*/
> +                       seq_puts(seq,  "FLOW_SEQ  "); /*in sequence flows*/
>                 else
> -                       seq_printf(seq,  "FLOW_RND  ");
> +                       seq_puts(seq,  "FLOW_RND  ");
>         }
>
>  #ifdef CONFIG_XFRM
>         if (pkt_dev->flags & F_IPSEC_ON) {
> -               seq_printf(seq,  "IPSEC  ");
> +               seq_puts(seq,  "IPSEC  ");
>                 if (pkt_dev->spi)
>                         seq_printf(seq, "spi:%u", pkt_dev->spi);
>         }
>  #endif
>
>         if (pkt_dev->flags & F_MACSRC_RND)
> -               seq_printf(seq, "MACSRC_RND  ");
> +               seq_puts(seq, "MACSRC_RND  ");
>
>         if (pkt_dev->flags & F_MACDST_RND)
> -               seq_printf(seq, "MACDST_RND  ");
> +               seq_puts(seq, "MACDST_RND  ");
>
>         if (pkt_dev->flags & F_VID_RND)
> -               seq_printf(seq, "VID_RND  ");
> +               seq_puts(seq, "VID_RND  ");
>
>         if (pkt_dev->flags & F_SVID_RND)
> -               seq_printf(seq, "SVID_RND  ");
> +               seq_puts(seq, "SVID_RND  ");
>
>         if (pkt_dev->flags & F_NODE)
> -               seq_printf(seq, "NODE_ALLOC  ");
> +               seq_puts(seq, "NODE_ALLOC  ");
>
>         if (pkt_dev->flags & F_NOINIT)
>                 seq_puts(seq, "NOINIT  ");
> @@ -720,7 +720,7 @@ static int pktgen_if_show(struct seq_file *seq, void *v)
>         if (pkt_dev->result[0])
>                 seq_printf(seq, "Result: %s\n", pkt_dev->result);
>         else
> -               seq_printf(seq, "Result: Idle\n");
> +               seq_puts(seq, "Result: Idle\n");
>
>         return 0;
>  }
> @@ -1745,14 +1745,14 @@ static int pktgen_thread_show(struct seq_file *seq, void *v)
>
>         BUG_ON(!t);
>
> -       seq_printf(seq, "Running: ");
> +       seq_puts(seq, "Running: ");
>
>         if_lock(t);
>         list_for_each_entry(pkt_dev, &t->if_list, list)
>                 if (pkt_dev->running)
>                         seq_printf(seq, "%s ", pkt_dev->odevname);
>
> -       seq_printf(seq, "\nStopped: ");
> +       seq_puts(seq, "\nStopped: ");
>
>         list_for_each_entry(pkt_dev, &t->if_list, list)
>                 if (!pkt_dev->running)
> @@ -1761,7 +1761,7 @@ static int pktgen_thread_show(struct seq_file *seq, void *v)
>         if (t->result[0])
>                 seq_printf(seq, "\nResult: %s\n", t->result);
>         else
> -               seq_printf(seq, "\nResult: NA\n");
> +               seq_puts(seq, "\nResult: NA\n");
>
>         if_unlock(t);
>
> --
> 1.8.3.1
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
