From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH 8/8] vxlan: Add support for zero UDP6 checksums
Date: Mon, 12 May 2014 14:41:12 -0700
Message-ID: <CAEP_g=9BTrUN48uV2teyufmG7QPZHmYsMrvWOBs9JhJam2oOVw@mail.gmail.com>
References: <alpine.DEB.2.02.1405120952470.12635@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na6sys009bog019.obsmtp.com ([74.125.150.78]:49981 "HELO
	na6sys009bog019.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752128AbaELVld (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 May 2014 17:41:33 -0400
Received: by mail-qa0-f42.google.com with SMTP id j5so7788851qaq.15
        for <netdev@vger.kernel.org>; Mon, 12 May 2014 14:41:32 -0700 (PDT)
In-Reply-To: <alpine.DEB.2.02.1405120952470.12635@tomh.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 12, 2014 at 9:59 AM, Tom Herbert <therbert@google.com> wrote:
> @@ -1756,7 +1754,8 @@ int vxlan_xmit_skb(struct vxlan_sock *vs,
>         uh->source = src_port;
>
>         uh->len = htons(skb->len);
> -       uh->check = 0;
> +
> +       udp_set_csum(vs->sock->sk, skb, src, dst, skb->len);

How does this interact with inner checksum offloading? I don't think
that we have any infrastructure to support computing two checksums on
a packet yet.
