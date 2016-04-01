From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net 4/4] tcp: various missing rcu_read_lock around
 __sk_dst_get
Date: Thu, 31 Mar 2016 20:03:38 -0700
Message-ID: <1459479818.6473.265.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1459466982-20432-1-git-send-email-hannes@stressinduktion.org>
	 <1459466982-20432-5-git-send-email-hannes@stressinduktion.org>
	 <1459467595.6473.233.camel@edumazet-glaptop3.roam.corp.google.com>
	 <56FDBA6E.5030508@stressinduktion.org>
	 <1459469572.6473.239.camel@edumazet-glaptop3.roam.corp.google.com>
	 <56FDBF0E.8020309@stressinduktion.org>
	 <1459473592.6473.243.camel@edumazet-glaptop3.roam.corp.google.com>
	 <20160401014516.GA11017@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	davem@davemloft.net, netdev@vger.kernel.org,
	sasha.levin@oracle.com, daniel@iogearbox.net, mkubecek@suse.cz
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:35199 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753140AbcDADDl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Mar 2016 23:03:41 -0400
Received: by mail-pa0-f44.google.com with SMTP id td3so79727730pab.2
        for <netdev@vger.kernel.org>; Thu, 31 Mar 2016 20:03:40 -0700 (PDT)
In-Reply-To: <20160401014516.GA11017@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-03-31 at 18:45 -0700, Alexei Starovoitov wrote:

> Eric, what's your take on Hannes's patch 2 ?
> Is it more accurate to ask lockdep to check for actual lock
> or lockdep can rely on owned flag?
> Potentially there could be races between setting the flag and
> actual lock... but that code is contained, so unlikely.
> Will we find the real issues with this 'stronger' check or
> just spend a ton of time adapting to new model like your other
> patch for release_sock and whatever may need to come next...

More precise lockdep checks are certainly good, I only objected to 4/4
trying to work around another bug.

But why do we rush for 'net' tree ?

This looks net-next material to me.

Locking changes are often subtle, lets take the time to do them
properly.
