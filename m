From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 9/9] net: add opaque struct around skb frag page
Date: Mon, 10 Oct 2011 17:09:35 +0200
Message-ID: <1318259375.3227.1.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1318245076.21903.408.camel@zakaz.uk.xensource.com>
	 <1318245101-16890-9-git-send-email-ian.campbell@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Ian Campbell <ian.campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:64843 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750730Ab1JJPJU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Oct 2011 11:09:20 -0400
Received: by eye27 with SMTP id 27so1463027eye.19
        for <netdev@vger.kernel.org>; Mon, 10 Oct 2011 08:09:19 -0700 (PDT)
In-Reply-To: <1318245101-16890-9-git-send-email-ian.campbell@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 10 octobre 2011 =C3=A0 12:11 +0100, Ian Campbell a =C3=A9crit =
:
> I've split this bit out of the skb frag destructor patch since it hel=
ps enforce
> the use of the fragment API.
>=20
> Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
> ---
>  include/linux/skbuff.h |   10 ++++++----
>  net/core/skbuff.c      |    6 +++---
>  2 files changed, 9 insertions(+), 7 deletions(-)
>=20
> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> index ac6b05a..f881d75 100644
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -135,7 +135,9 @@ struct sk_buff;
>  typedef struct skb_frag_struct skb_frag_t;
> =20
>  struct skb_frag_struct {
> -	struct page *page;
> +	struct {
> +		struct page *p;
> +	} page;

Oh well, why dont you rename page to something else, say frag_page ?
