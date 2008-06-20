From: "Michal Ostrowski" <mostrows@gmail.com>
Subject: Re: [PATCH] pppoe: warning fix
Date: Fri, 20 Jun 2008 18:41:44 -0500
Message-ID: <e6d1cecd0806201641y602ca494o7730302357664f06@mail.gmail.com>
References: <20080620161912.56f4b557@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Michal Ostrowski" <mostrows@earthlink.net>, netdev@vger.kernel.org
To: "Stephen Hemminger" <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.190]:33583 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755216AbYFTXlq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jun 2008 19:41:46 -0400
Received: by fk-out-0910.google.com with SMTP id 18so1449539fkq.5
        for <netdev@vger.kernel.org>; Fri, 20 Jun 2008 16:41:44 -0700 (PDT)
In-Reply-To: <20080620161912.56f4b557@extreme>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Acked-by: Michal Ostrowski <mostrows@earthlink.net>



On Fri, Jun 20, 2008 at 6:19 PM, Stephen Hemminger
<shemminger@vyatta.com> wrote:
> Fix warning:
> drivers/net/pppoe.c: In function 'pppoe_recvmsg':
> drivers/net/pppoe.c:945: warning: comparison of distinct pointer types lacks a cast
> because skb->len is unsigned int and total_len is size_t
>
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>
>
> --- a/drivers/net/pppoe.c       2008-06-20 15:56:46.000000000 -0700
> +++ b/drivers/net/pppoe.c       2008-06-20 15:57:04.000000000 -0700
> @@ -942,7 +942,7 @@ static int pppoe_recvmsg(struct kiocb *i
>        m->msg_namelen = 0;
>
>        if (skb) {
> -               total_len = min(total_len, skb->len);
> +               total_len = min_t(size_t, total_len, skb->len);
>                error = skb_copy_datagram_iovec(skb, 0, m->msg_iov, total_len);
>                if (error == 0)
>                        error = total_len;
>
