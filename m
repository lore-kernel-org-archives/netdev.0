From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [PATCH] net: diag: Tell user if support for destroying TCP
 sockets is not enabled
Date: Tue, 17 May 2016 09:49:30 +0900
Message-ID: <CAKD1Yr1Kk_cJkorZdp2+83GqBhVPW2Rn-nT5_FsFWwdkSvqMiQ@mail.gmail.com>
References: <1463442791-2399-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f177.google.com ([209.85.161.177]:36691 "EHLO
	mail-yw0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750934AbcEQAtv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 May 2016 20:49:51 -0400
Received: by mail-yw0-f177.google.com with SMTP id x189so944701ywe.3
        for <netdev@vger.kernel.org>; Mon, 16 May 2016 17:49:51 -0700 (PDT)
In-Reply-To: <1463442791-2399-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 17, 2016 at 8:53 AM, David Ahern <dsa@cumulusnetworks.com> wrote:
> +#else
> +static int tcp_diag_destroy(struct sk_buff *in_skb,
> +                           const struct inet_diag_req_v2 *req)
> +{
> +       return -EOPNOTSUPP;
> +}
>  #endif

I don't understand why you need this. inet_diag_cmd_exact already
returns EOPNOTSUPP if tcp_diag_handler.destroy is NULL:

        else if (cmd == SOCK_DIAG_BY_FAMILY)
                err = handler->dump_one(in_skb, nlh, req);
        else if (cmd == SOCK_DESTROY && handler->destroy)
                err = handler->destroy(in_skb, req);
        else
                err = -EOPNOTSUPP;

Is this not working for some reason?
