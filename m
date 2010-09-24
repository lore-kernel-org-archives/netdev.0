From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/2] Phonet: Implement Pipe Controller to support Nokia
 Slim Modems
Date: Fri, 24 Sep 2010 15:52:13 +0200
Message-ID: <1285336333.2503.153.camel@edumazet-laptop>
References: <1285330996-27076-1-git-send-email-kumar.sanghvi@stericsson.com>
	 <1285330996-27076-2-git-send-email-kumar.sanghvi@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: remi.denis-courmont@nokia.com, davem@davemloft.net,
	netdev@vger.kernel.org, STEricsson_nomadik_linux@list.st.com,
	sudeep.divakaran@stericsson.com, gulshan.karmani@stericsson.com,
	Linus Walleij <linus.walleij@stericsson.com>
To: Kumar A Sanghvi <kumar.sanghvi@stericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:33334 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932158Ab0IXNwT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Sep 2010 09:52:19 -0400
Received: by fxm3 with SMTP id 3so696265fxm.19
        for <netdev@vger.kernel.org>; Fri, 24 Sep 2010 06:52:18 -0700 (PDT)
In-Reply-To: <1285330996-27076-2-git-send-email-kumar.sanghvi@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 24 septembre 2010 =C3=A0 17:53 +0530, Kumar A Sanghvi a =C3=
=A9crit :

> +static int pipe_get_flow_info(struct sock *sk, struct sk_buff *skb,
> +		u8 *pref_rx_fc, u8 *req_tx_fc)
> +{
> +	struct pnpipehdr *hdr =3D pnp_hdr(skb);
> +	u8 n_sb;
> +
> +	if (!pskb_may_pull(skb, sizeof(*hdr) + 4))
> +		return -EINVAL;

This is wrong.

pskb_may_pull() might change skb->data, so you should do

{
	struct pnpipehdr *hdr;
	u8 n_sb;

	if (!pskb_may_pull(skb, sizeof(*hdr) + 4))
		return -EINVAL;

	hdr =3D pnp_hdr(skb);

=2E..





