From: Yann Ylavic <ylavic.dev@gmail.com>
Subject: Re: [PATCH net-next 8/8] net/mlx4_en: Extend checksum offloading by
 CHECKSUM COMPLETE
Date: Fri, 31 Oct 2014 01:38:13 +0100
Message-ID: <CAKQ1sVNu9AN=gaRQfgqWq635YBZjEHegz0Ljj3xvvcDSoFaU=A@mail.gmail.com>
References: <1414685216-28907-1-git-send-email-ogerlitz@mellanox.com>
	<1414685216-28907-9-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Matan Barak <matanb@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Shani Michaeli <shanim@mellanox.com>,
	Jerry Chu <hkchu@google.com>
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f169.google.com ([209.85.223.169]:39799 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161365AbaJaAiO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2014 20:38:14 -0400
Received: by mail-ie0-f169.google.com with SMTP id tr6so292292ieb.14
        for <netdev@vger.kernel.org>; Thu, 30 Oct 2014 17:38:13 -0700 (PDT)
In-Reply-To: <1414685216-28907-9-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Thu, Oct 30, 2014 at 5:06 PM, Or Gerlitz <ogerlitz@mellanox.com> wrote:
[...]
> +static int check_csum(struct mlx4_cqe *cqe, struct sk_buff *skb, int hwtstamp_rx_filter)
> +{
> +       __wsum hw_checksum = 0;
> +
> +       void *hdr = (u8 *)skb->data + sizeof(struct ethhdr);
> +
> +       hw_checksum = csum_unfold((__force __sum16)cqe->checksum);
> +
> +       if (((struct ethhdr *)skb->data)->h_proto == htons(ETH_P_8021Q) &&
> +           hwtstamp_rx_filter != HWTSTAMP_FILTER_NONE) {
> +               /* next protocol non IPv4 or IPv6 */
> +               if (((struct vlan_hdr *)hdr)->h_vlan_encapsulated_proto
> +                   != htons(ETH_P_IP) ||

Shouldn't this be a AND (&&)?

> +                   ((struct vlan_hdr *)hdr)->h_vlan_encapsulated_proto
> +                   != htons(ETH_P_IPV6))
> +                       return -1;

Regards,
Yann.
