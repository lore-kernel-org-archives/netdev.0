From: Xin Long <lucien.xin@gmail.com>
Subject: Re: [net-next,v2] ip_gre: check packet length and mtu correctly in
 erspan tx
Date: Fri, 6 Oct 2017 19:03:14 +0800
Message-ID: <CADvbK_d7bQNJS_vUk=Q+HrSz8BcJWt=H6xm26ADEZKZGuCy6qw@mail.gmail.com>
References: <1507230432-56495-1-git-send-email-u9012063@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: network dev <netdev@vger.kernel.org>,
        David Laight <David.Laight@aculab.com>
To: William Tu <u9012063@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f195.google.com ([209.85.216.195]:46176 "EHLO
        mail-qt0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750849AbdJFLDP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Oct 2017 07:03:15 -0400
Received: by mail-qt0-f195.google.com with SMTP id 6so21537407qtw.3
        for <netdev@vger.kernel.org>; Fri, 06 Oct 2017 04:03:15 -0700 (PDT)
In-Reply-To: <1507230432-56495-1-git-send-email-u9012063@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 6, 2017 at 3:07 AM, William Tu <u9012063@gmail.com> wrote:
> Similarly to early patch for erspan_xmit(), the ARPHDR_ETHER device
> is the length of the whole ether packet.  So skb->len should subtract
> the dev->hard_header_len.
>
> Fixes: 1a66a836da63 ("gre: add collect_md mode to ERSPAN tunnel")
> Fixes: 84e54fe0a5ea ("gre: introduce native tunnel support for ERSPAN")
> Signed-off-by: William Tu <u9012063@gmail.com>
> Cc: Xin Long <lucien.xin@gmail.com>
> Cc: David Laight <David.Laight@aculab.com>
> ---
> v1->v2:
> use addition to avoid overflow
> fix pskb_trim size
> ---
>  net/ipv4/ip_gre.c | 8 ++++----
>  1 file changed, 4 insertions(+), 4 deletions(-)
>
> diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
> index b279c325c7f6..fb95f68d6e53 100644
> --- a/net/ipv4/ip_gre.c
> +++ b/net/ipv4/ip_gre.c
> @@ -579,8 +579,8 @@ static void erspan_fb_xmit(struct sk_buff *skb, struct net_device *dev,
>         if (gre_handle_offloads(skb, false))
>                 goto err_free_rt;
>
> -       if (skb->len > dev->mtu) {
> -               pskb_trim(skb, dev->mtu);
> +       if (skb->len > dev->mtu + dev->hard_header_len) {
> +               pskb_trim(skb, dev->mtu + dev->hard_header_len);
>                 truncate = true;
>         }
>
> @@ -731,8 +731,8 @@ static netdev_tx_t erspan_xmit(struct sk_buff *skb,
>         if (skb_cow_head(skb, dev->needed_headroom))
>                 goto free_skb;
>
> -       if (skb->len - dev->hard_header_len > dev->mtu) {
> -               pskb_trim(skb, dev->mtu);
> +       if (skb->len > dev->mtu + dev->hard_header_len) {
> +               pskb_trim(skb, dev->mtu + dev->hard_header_len);
>                 truncate = true;
>         }
>
> --
> 2.7.4
>
Reviewed-by: Xin Long <lucien.xin@gmail.com>
