From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] packet: fix potential use after free
Date: Thu, 10 Apr 2014 08:06:58 -0700
Message-ID: <1397142418.16584.28.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1397092959.16584.26.camel@edumazet-glaptop2.roam.corp.google.com>
	 <53465409.3070507@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Xi Wang <xii@google.com>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:44192 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752918AbaDJPHA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Apr 2014 11:07:00 -0400
Received: by mail-pd0-f170.google.com with SMTP id v10so4017792pde.1
        for <netdev@vger.kernel.org>; Thu, 10 Apr 2014 08:07:00 -0700 (PDT)
In-Reply-To: <53465409.3070507@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-04-10 at 10:19 +0200, Daniel Borkmann wrote:
> On 04/10/2014 03:22 AM, Eric Dumazet wrote:
> > From: Eric Dumazet <edumazet@google.com>
> >
> > As soon skb is queued into sk_receive_queue, it can be consumed,
> > so its racy to access skb->len.
> >
> > Given that sk_data_ready() / sock_def_readable() don't really care, just
> > use 0 instead of skb->len
> >
> > Signed-off-by: Eric Dumazet <edumazet@google.com>
> > Cc: Xi Wang <xii@google.com>
> 
> Acked-by: Daniel Borkmann <dborkman@redhat.com>
> 
> Seems to be there since pre 2005 ...

Yeah, and many other places have the same error, a full audit is
probably needed.
