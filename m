From: Eric Dumazet <erdnetdev@gmail.com>
Subject: Re: [PATCH] xen/netfront: improve truesize tracking
Date: Thu, 20 Dec 2012 07:39:28 -0800
Message-ID: <1356017968.21834.2859.camel@edumazet-glaptop>
References: <1355838711-5473-1-git-send-email-ian.campbell@citrix.com>
	 <1355843525.9380.18.camel@edumazet-glaptop>
	 <1355844398.14620.254.camel@zakaz.uk.xensource.com>
	 <55633610.20121219123427@eikelenboom.it>
	 <1355933869.21834.13.camel@edumazet-glaptop>
	 <1797374383.20121220135139@eikelenboom.it>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ian Campbell <Ian.Campbell@citrix.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	annie li <annie.li@oracle.com>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>
To: Sander Eikelenboom <linux@eikelenboom.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:34039 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751168Ab2LTPja (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Dec 2012 10:39:30 -0500
Received: by mail-pb0-f46.google.com with SMTP id wy7so2058840pbc.5
        for <netdev@vger.kernel.org>; Thu, 20 Dec 2012 07:39:30 -0800 (PST)
In-Reply-To: <1797374383.20121220135139@eikelenboom.it>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-12-20 at 13:51 +0100, Sander Eikelenboom wrote:

> Eric:
>      From the warn_on_once, delta should be smaller than len, but probably they should be as close together as possible.
>      When you say "accurate estimation", what would be a acceptable difference between DELTA and LEN ?

I would use the most exact value, which is :

   skb->truesize += nr_frags * PAGE_SIZE;

Then, if we can spot later a regression in some stacks, adapt the
limiting parameters. I did a lot of work in GRO and TCP stack to reduce
the memory, and further changes are possible.

We really want to account memory, because we want to control how memory
is used on our machines and don't let some users use more than the
amount that was allowed to them.
