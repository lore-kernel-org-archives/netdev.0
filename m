From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 3.5 bridging regression
Date: Sun, 21 Oct 2012 15:46:42 +0200
Message-ID: <1350827202.13333.2284.camel@edumazet-glaptop>
References: <20121021112727.GF21937@1wt.eu>
	 <1350820413.13333.2042.camel@edumazet-glaptop>
	 <20121021132610.GG21937@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f174.google.com ([209.85.215.174]:42505 "EHLO
	mail-ea0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753583Ab2JUNqq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Oct 2012 09:46:46 -0400
Received: by mail-ea0-f174.google.com with SMTP id c13so551892eaa.19
        for <netdev@vger.kernel.org>; Sun, 21 Oct 2012 06:46:45 -0700 (PDT)
In-Reply-To: <20121021132610.GG21937@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2012-10-21 at 15:26 +0200, Willy Tarreau wrote:
> On Sun, Oct 21, 2012 at 01:53:33PM +0200, Eric Dumazet wrote:
> > Hello Willy
> > 
> > This is most probably the needed fix.
> 
> Good catch, as usual ! It works flawlessly here on top of 3.6.2.
> 
> > I guess David planned to send it to stable teams if not already done.
> 
> Indeed, I've not seen it there yet.
> 
> David, are you OK with sending this patch for -stable ? It fixes
> a 3.5 regression causing bridge to panic.
> 
> > commit acb600def2110b1310466c0e485c0d26299898ae
> > Author: Eric Dumazet <edumazet@google.com>
> > Date:   Fri Oct 5 06:23:55 2012 +0000
> > 
> >     net: remove skb recycling
> >     
> >     Over time, skb recycling infrastructure got litle interest and
> >     many bugs. Generic rx path skb allocation is now using page
> >     fragments for efficient GRO / TCP coalescing, and recyling
> >     a tx skb for rx path is not worth the pain.
> 
> Thanks and have a nice week-end !
> Willy
> 

Thanks for testing, sorry for adding a bug.

skb_recycle() was losing skb->head_frag status.

(we could have added some logic in skb_is_recycleable(), but this
function was becoming really too complex)
