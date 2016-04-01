From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net 4/4] tcp: various missing rcu_read_lock around
 __sk_dst_get
Date: Fri, 01 Apr 2016 05:06:53 +0200
Message-ID: <1459480013.3772171.565370082.48F59FEC@webmail.messagingengine.com>
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
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	sasha.levin@oracle.com, daniel@iogearbox.net, mkubecek@suse.cz
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:47937 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753140AbcDADGz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Mar 2016 23:06:55 -0400
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id 06B2320CC7
	for <netdev@vger.kernel.org>; Thu, 31 Mar 2016 23:06:54 -0400 (EDT)
In-Reply-To: <1459479818.6473.265.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 1, 2016, at 05:03, Eric Dumazet wrote:
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

I certainly can see my mistake now trying to paper over the splats. Do
you object if I send the first patches to fix up the reported lockdep?
