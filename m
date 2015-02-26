From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH net 2/2] rhashtable: remove indirection for grow/shrink
 decision functions
Date: Thu, 26 Feb 2015 14:54:18 +0000
Message-ID: <20150226145418.GD5498@acer.localdomain>
References: <CAADnVQKV8JSqhTPYBGDJt4KqTesEvtCMnhupiPyZJjvk=tmOwg@mail.gmail.com>
 <20150226075354.GA30061@acer.localdomain>
 <1424962236.5565.156.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	David Laight <David.Laight@aculab.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"tgraf@suug.ch" <tgraf@suug.ch>,
	"pablo@netfilter.org" <pablo@netfilter.org>,
	"johunt@akamai.com" <johunt@akamai.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:64798 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753190AbbBZOyY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2015 09:54:24 -0500
Content-Disposition: inline
In-Reply-To: <1424962236.5565.156.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 26.02, Eric Dumazet wrote:
> On Thu, 2015-02-26 at 07:53 +0000, Patrick McHardy wrote:
> 
> > My understanding was that Eric was arguing against shrinking in general.
> > But assuming we have it, what's the downside of also performing
> > shrinking for TCP?
> 
> Hash resize is horribly expensive (this is general to all hash
> implementations), so once you took the risk to expand the table once,
> you do not want to take the risk another time. You are lucky if host was
> not already taken out of the server pool.

Well, it's async, so I'd hope it wouldn't take you out of your server
pool. But sure, for TCP your point seems reasonable, as long as we'll
keep it available for nftables I'm happy.

> Fact that cond_resched() is not yet used anywhere in lib/rhashtable.c
> reveals part of the problem we have here.
> 
> (I'll submit patches for that)

Reminds me that I also need this for nft set GC, thanks :)
