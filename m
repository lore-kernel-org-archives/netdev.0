From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net] udp: prevent skbs lingering in tunnel socket queues
Date: Thu, 19 May 2016 15:33:34 -0700
Message-ID: <CAM_iQpXOxcT+P2mxF9okdeD2d-=mXXxba6c-AQk-hgv7qian2A@mail.gmail.com>
References: <1463666313-12743-1-git-send-email-hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f196.google.com ([209.85.161.196]:33961 "EHLO
	mail-yw0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932132AbcESWdz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 May 2016 18:33:55 -0400
Received: by mail-yw0-f196.google.com with SMTP id i22so12513555ywc.1
        for <netdev@vger.kernel.org>; Thu, 19 May 2016 15:33:54 -0700 (PDT)
In-Reply-To: <1463666313-12743-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 19, 2016 at 6:58 AM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
> index 2e3ebfe5549ef5..d56c0559b477cb 100644
> --- a/net/ipv4/udp.c
> +++ b/net/ipv4/udp.c
> @@ -1565,7 +1565,7 @@ int udp_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
>
>                 /* if we're overly short, let UDP handle it */
>                 encap_rcv = ACCESS_ONCE(up->encap_rcv);
> -               if (skb->len > sizeof(struct udphdr) && encap_rcv) {
> +               if (encap_rcv) {


I don't think you can just remove it here, l2tp_udp_recv_core() still
relies on it:

        /* UDP has verifed checksum */

        /* UDP always verifies the packet length. */
        __skb_pull(skb, sizeof(struct udphdr));
