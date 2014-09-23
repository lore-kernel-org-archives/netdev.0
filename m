From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/5] netfilter: nft_rbtree: no need for spinlock from
 set destroy path
Date: Tue, 23 Sep 2014 09:29:37 -0700
Message-ID: <1411489777.15395.1.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1411464288-18069-1-git-send-email-pablo@netfilter.org>
	 <1411464288-18069-3-git-send-email-pablo@netfilter.org>
	 <1411465957.26859.179.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140923110159.GA20055@salvia>
	 <1411473245.26859.188.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140923161040.GA3609@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:64920 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932215AbaIWQ3g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Sep 2014 12:29:36 -0400
In-Reply-To: <20140923161040.GA3609@salvia>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-09-23 at 18:10 +0200, Pablo Neira Ayuso wrote:

> Actually, I could add to nft_data a pointer in the union area, but I'm
> not very confortable with adding it for this specific case. At this
> moment we're releasing this from rcu_callback which is "hiding" the
> deletion time from the netlink interface.
> 
> But I'll keep this back in my head if we later on have some pointer
> candidate to be reused in a nice way.
> 
> I'll send a patch to make the rb_first()/rb_next() conversion though.

Ah, forget what I said, its actually slower to build a list by 7%, I had
an error in my test.

So the rb_first() thing is the easy and fast way.

Thanks
