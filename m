From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: gro: change GRO overflow strategy
Date: Thu, 09 Jan 2014 17:08:57 -0800
Message-ID: <1389316137.31367.76.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1389305539.31367.65.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAHA+R7M1wYwLA32fw=jzOUTR1+_zy8K9ugJohLmv1Tr1UHdhTw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Jerry Chu <hkchu@google.com>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f46.google.com ([209.85.213.46]:59159 "EHLO
	mail-yh0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751330AbaAJBJA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jan 2014 20:09:00 -0500
Received: by mail-yh0-f46.google.com with SMTP id 29so1115898yhl.19
        for <netdev@vger.kernel.org>; Thu, 09 Jan 2014 17:09:00 -0800 (PST)
In-Reply-To: <CAHA+R7M1wYwLA32fw=jzOUTR1+_zy8K9ugJohLmv1Tr1UHdhTw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-01-09 at 16:44 -0800, Cong Wang wrote:
> On Thu, Jan 9, 2014 at 2:12 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > +               /* locate the end of the list to select the 'oldest' flow */
> > +               while (nskb->next) {
> > +                       pp = &nskb->next;
> > +                       nskb = *pp;
> > +               }
> > +               *pp = NULL;
> > +               nskb->next = NULL;
> 
> How long could this list be?
> 

#define MAX_GRO_SKBS 8

> I think it's time to use doubly linked list for gro,
> although definitely not in this patch.

Its not needed, and it would be slower.

In fast path, we do not need to get the previous pointers.
