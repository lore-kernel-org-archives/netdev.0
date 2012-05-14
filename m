From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: codel: fix build errors
Date: Mon, 14 May 2012 23:49:12 +0200
Message-ID: <1337032152.8512.638.camel@edumazet-glaptop>
References: <1337015687-17693-1-git-send-email-levinsasha928@gmail.com>
	 <1337029683.8512.626.camel@edumazet-glaptop>
	 <CA+1xoqfWR+BA4xqqG+8SzVGYSH1z6nu_=iEFX7XoZzMhv_GvqA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, dave.taht@bufferbloat.net,
	davem@davemloft.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Sasha Levin <levinsasha928@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:55033 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932234Ab2ENVtR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 May 2012 17:49:17 -0400
In-Reply-To: <CA+1xoqfWR+BA4xqqG+8SzVGYSH1z6nu_=iEFX7XoZzMhv_GvqA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-05-14 at 23:39 +0200, Sasha Levin wrote:
> On Mon, May 14, 2012 at 11:08 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > Anonymous unions are fine, we use them a lot in kernel.
> 
> While we use them a lot, we don't try initializing them that often.
> 
> > Please fix the initializers instead in fq_codel_dump_stats(), because
> > these two #define are not very nice.
> 
> The only method I know of fixing that up is getting braces around them
> in the initializer, which is hacky and will break every time a new
> member is added to the struct before the anonymous union. Is there a
> different solution?


instead of 

	struct foo x = {
		.field = value;
		.sub.f2 = xxx;
		...
	};

use :

	struct foo x = {
		.field = value;
	};

	x.sub.f2 = xxx;
	...
