From: Eric Sesterhenn <snakebyte@gmx.de>
Subject: Re: Inconsistend lock state in inet_frag_find
Date: Fri, 30 May 2008 23:13:15 +0200
Message-ID: <20080530211315.GA16064@alice>
References: <20080529120248.GA9702@alice> <20080530105334.GA7378@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:54498 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1753269AbYE3VNS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 May 2008 17:13:18 -0400
Content-Disposition: inline
In-Reply-To: <20080530105334.GA7378@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Jarek Poplawski (jarkao2@gmail.com) wrote:
>On Fri, May 30, 2008 at 03:18:45PM +0200, Eric Sesterhenn wrote:
>...
>> with the patch applied i get the following lockdep warning:
>> 
>> [   63.531438] =================================
>> [   63.531520] [ INFO: inconsistent lock state ]
>> [   63.531520] 2.6.26-rc4 #7
>> [   63.531520] ---------------------------------
>> [   63.531520] inconsistent {softirq-on-W} -> {in-softirq-W} usage.
>> [   63.531520] tcpsic6/3864 [HC0[0]:SC1[1]:HE1:SE0] takes:
>> [   63.531520]  (&q->lock#2){-+..}, at: [<c07175b0>]
>> ipv6_frag_rcv+0xd0/0xbd0
>> [   63.531520] {softirq-on-W} state was registered at:
>> [   63.531520]   [<c0143bba>] __lock_acquire+0x3aa/0x1080
>> [   63.531520]   [<c0144906>] lock_acquire+0x76/0xa0
>> [   63.531520]   [<c07a8f0b>] _spin_lock+0x2b/0x40
>> [   63.531520]   [<c0727636>] nf_ct_frag6_gather+0x3f6/0x910
> ...
>
> I hope it's not a Pandora's Box: looks like there are still a few of
> these locks around, which could make more such reports, but since I
> don't know this code, I'd prefer not to go ahead of lockdep...

looks like we got lucky :-)

> (Take 2: please revert the previous patch before applying.)

This one does the trick, i let tcp6sic run a bit longer and didnt
see any more lockdep warnings. 

Thanks, Eric
