From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH net-next] net: gro: change GRO overflow strategy
Date: Thu, 9 Jan 2014 16:44:41 -0800
Message-ID: <CAHA+R7M1wYwLA32fw=jzOUTR1+_zy8K9ugJohLmv1Tr1UHdhTw@mail.gmail.com>
References: <1389305539.31367.65.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Jerry Chu <hkchu@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f181.google.com ([209.85.217.181]:47017 "EHLO
	mail-lb0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756638AbaAJAon (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jan 2014 19:44:43 -0500
Received: by mail-lb0-f181.google.com with SMTP id z5so536165lbh.40
        for <netdev@vger.kernel.org>; Thu, 09 Jan 2014 16:44:42 -0800 (PST)
In-Reply-To: <1389305539.31367.65.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 9, 2014 at 2:12 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> +               /* locate the end of the list to select the 'oldest' flow */
> +               while (nskb->next) {
> +                       pp = &nskb->next;
> +                       nskb = *pp;
> +               }
> +               *pp = NULL;
> +               nskb->next = NULL;

How long could this list be?

I think it's time to use doubly linked list for gro,
although definitely not in this patch.
