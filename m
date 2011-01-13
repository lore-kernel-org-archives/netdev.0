From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH] tcp: remove duplicate th = tcp_hdr(skb)
Date: Thu, 13 Jan 2011 10:54:14 -0500
Message-ID: <AANLkTim3qQX2NhqZ99BF00WnviRi898aw7XE7BcJFfHH@mail.gmail.com>
References: <1294933302-28469-1-git-send-email-christoph.paasch@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Christoph Paasch <christoph.paasch@uclouvain.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:42909 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755832Ab1AMPyQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jan 2011 10:54:16 -0500
Received: by ywl5 with SMTP id 5so489008ywl.19
        for <netdev@vger.kernel.org>; Thu, 13 Jan 2011 07:54:15 -0800 (PST)
In-Reply-To: <1294933302-28469-1-git-send-email-christoph.paasch@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 13, 2011 at 10:41 AM, Christoph Paasch
<christoph.paasch@uclouvain.be> wrote:
> th is already set some lines before to be th =3D tcp_hdr(skb).
>
> Signed-off-by: Christoph Paasch <christoph.paasch@uclouvain.be>
> ---
> =A0net/ipv4/tcp_ipv4.c | =A0 =A01 -
> =A01 files changed, 0 insertions(+), 1 deletions(-)
>
> diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
> index 856f684..7fe29c6 100644
> --- a/net/ipv4/tcp_ipv4.c
> +++ b/net/ipv4/tcp_ipv4.c
> @@ -1644,7 +1644,6 @@ int tcp_v4_rcv(struct sk_buff *skb)
> =A0 =A0 =A0 =A0if (!skb_csum_unnecessary(skb) && tcp_v4_checksum_init=
(skb))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto bad_packet;
>
> - =A0 =A0 =A0 th =3D tcp_hdr(skb);

It needs to be reloaded because pskb_may_pull() may reallocate the buff=
er.
