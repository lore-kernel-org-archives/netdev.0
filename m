From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: Re: [PATCH net RFC] xen-netback: Fix grant ref resolution in RX path
Date: Thu, 15 May 2014 11:14:25 +0100
Message-ID: <53749381.7010301@citrix.com>
References: <1399991500-4432-1-git-send-email-zoltan.kiss@citrix.com>	 <1399997635.7973.56.camel@edumazet-glaptop2.roam.corp.google.com>	 <53734F9F.2010101@citrix.com> <1400142682.30687.3.camel@kazak.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	<xen-devel@lists.xenproject.org>, <wei.liu2@citrix.com>,
	<linux@eikelenboom.it>, <paul.durrant@citrix.com>,
	<netdev@vger.kernel.org>, <david.vrabel@citrix.com>,
	<davem@davemloft.net>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:20786 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751951AbaEOKO3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 May 2014 06:14:29 -0400
In-Reply-To: <1400142682.30687.3.camel@kazak.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15/05/14 09:31, Ian Campbell wrote:
> On Wed, 2014-05-14 at 12:12 +0100, Zoltan Kiss wrote:
>>> The 'cleanup' of stale ubufs should be right after __pskb_pull_tail().
>> We can't fix every place in the kernel where frags might be changed,
>> especially with a netback specific stuff, so unfortunately that won't work
>
> Is it worth fixing up the ones in netback though so that the things
> injected into the stack are consistent when we hand them over? It would
> avoid some search overhead on the rx path at the other end I guess?
> Perhaps not significant though.

There are plans to remove that unconditional pull, as it damages 
performance. It is better to use during checksum setup maybe_pull_tail, 
and pull up whatever is needed for checksum setup (this is already done, 
partially). A sensible netfront would send the header in the first slot 
anyway, so netback won't pull, and it definitely won't pull the whole 
first frag.

Regards,

Zoli
