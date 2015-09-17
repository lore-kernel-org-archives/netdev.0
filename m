From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH] geneve: remove use of internal IP header when calling IP_ECN_decapsulate
Date: Thu, 17 Sep 2015 12:46:48 -0700
Message-ID: <CAEP_g=8Hjcae1zrzV2--j6J3rsXfZmexnGsziA3OTmezdLtbkA@mail.gmail.com>
References: <1442510271-10110-1-git-send-email-linville@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f41.google.com ([209.85.215.41]:34540 "EHLO
	mail-la0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751630AbbIQTrJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Sep 2015 15:47:09 -0400
Received: by lahg1 with SMTP id g1so18240380lah.1
        for <netdev@vger.kernel.org>; Thu, 17 Sep 2015 12:47:07 -0700 (PDT)
In-Reply-To: <1442510271-10110-1-git-send-email-linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 17, 2015 at 10:17 AM, John W. Linville
<linville@tuxdriver.com> wrote:
> diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
> index da3259ce7c8d..a917ae1cfbf3 100644
> --- a/drivers/net/geneve.c
> +++ b/drivers/net/geneve.c
> @@ -178,13 +178,15 @@ static void geneve_rx(struct geneve_sock *gs, struct sk_buff *skb)
>
>         skb_reset_network_header(skb);
>
> -       iph = ip_hdr(skb); /* Now inner IP header... */
> -       err = IP_ECN_decapsulate(iph, skb);
> +       if (iph)
> +               err = IP_ECN_decapsulate(iph, skb);

It looks like this is now conditional based on !collect_md. I'm not
sure that we want to have a difference in behavior between the two.
