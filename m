From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: refactor sk_page_frag_refill()
Date: Sat, 12 Oct 2013 17:55:34 -0700
Message-ID: <1381625734.3392.26.camel@edumazet-glaptop.roam.corp.google.com>
References: <1380787003-20488-1-git-send-email-dborkman@redhat.com>
	 <1380805381.19002.206.camel@edumazet-glaptop.roam.corp.google.com>
	 <CANJ5vPJpVfDjaC8JauGYu=Qe4ZshqmBMkCbB1cru-xAfa7K1+g@mail.gmail.com>
	 <1381623952.3392.25.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <dborkman@redhat.com>, davem@davemloft.net,
	netdev@vger.kernel.org, Francesco Fusco <ffusco@redhat.com>,
	ycheng@google.com, Neal Cardwell <ncardwell@google.com>,
	Eric Northup <digitaleric@google.com>
To: Michael Dalton <mwdalton@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:41633 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752971Ab3JMAzf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Oct 2013 20:55:35 -0400
Received: by mail-pa0-f49.google.com with SMTP id ld10so5967875pab.8
        for <netdev@vger.kernel.org>; Sat, 12 Oct 2013 17:55:35 -0700 (PDT)
In-Reply-To: <1381623952.3392.25.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2013-10-12 at 17:25 -0700, Eric Dumazet wrote:

> -		if (pfrag->offset < pfrag->size)
> +		if (pfrag->offset + sz < pfrag->size)
>  			return true;
>  		put_page(pfrag->page);

This needs to be :

if (pfrag->offset + sz <= pfrag->size)

I'll send a v2
