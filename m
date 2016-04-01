From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net 4/4] tcp: various missing rcu_read_lock around
 __sk_dst_get
Date: Thu, 31 Mar 2016 21:04:44 -0700
Message-ID: <20160401040442.GA14661@ast-mbp.thefacebook.com>
References: <1459466982-20432-1-git-send-email-hannes@stressinduktion.org>
 <1459466982-20432-5-git-send-email-hannes@stressinduktion.org>
 <1459467595.6473.233.camel@edumazet-glaptop3.roam.corp.google.com>
 <56FDBA6E.5030508@stressinduktion.org>
 <1459469572.6473.239.camel@edumazet-glaptop3.roam.corp.google.com>
 <56FDBF0E.8020309@stressinduktion.org>
 <1459473592.6473.243.camel@edumazet-glaptop3.roam.corp.google.com>
 <20160401014516.GA11017@ast-mbp.thefacebook.com>
 <1459479818.6473.265.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	davem@davemloft.net, netdev@vger.kernel.org,
	sasha.levin@oracle.com, daniel@iogearbox.net, mkubecek@suse.cz
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:33034 "EHLO
	mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750740AbcDAEEu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Apr 2016 00:04:50 -0400
Received: by mail-pf0-f174.google.com with SMTP id 4so84886707pfd.0
        for <netdev@vger.kernel.org>; Thu, 31 Mar 2016 21:04:50 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1459479818.6473.265.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 31, 2016 at 08:03:38PM -0700, Eric Dumazet wrote:
> On Thu, 2016-03-31 at 18:45 -0700, Alexei Starovoitov wrote:
> 
> > Eric, what's your take on Hannes's patch 2 ?
> > Is it more accurate to ask lockdep to check for actual lock
> > or lockdep can rely on owned flag?
> > Potentially there could be races between setting the flag and
> > actual lock... but that code is contained, so unlikely.
> > Will we find the real issues with this 'stronger' check or
> > just spend a ton of time adapting to new model like your other
> > patch for release_sock and whatever may need to come next...
> 
> More precise lockdep checks are certainly good, I only objected to 4/4
> trying to work around another bug.
> 
> But why do we rush for 'net' tree ?
> 
> This looks net-next material to me.
> 
> Locking changes are often subtle, lets take the time to do them
> properly.

completely agree. I think only first patch belongs in net.
Everything else is net-next material.
