From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: Re: [PATCH net RFC] xen-netback: Fix grant ref resolution in RX path
Date: Wed, 14 May 2014 19:44:04 +0100
Message-ID: <5373B974.6050808@citrix.com>
References: <1399991500-4432-1-git-send-email-zoltan.kiss@citrix.com>	 <1399997635.7973.56.camel@edumazet-glaptop2.roam.corp.google.com>	 <53734F9F.2010101@citrix.com>	 <1400067318.7973.69.camel@edumazet-glaptop2.roam.corp.google.com>	 <53736EBA.7050401@citrix.com> <1400085639.26934.17.camel@kazak.uk.xensource.com>
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
Received: from smtp.citrix.com ([66.165.176.89]:2554 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750750AbaENSo0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 May 2014 14:44:26 -0400
In-Reply-To: <1400085639.26934.17.camel@kazak.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 14/05/14 17:40, Ian Campbell wrote:
>
> On Wed, 2014-05-14 at 14:25 +0100, Zoltan Kiss wrote:
>
>> But of course it should be carefully checked that functions which place
>> frags into another frags arrays should call orphan_frags, e.g. I guess
>> skb_shift does such thing. That's what I intend to start another thread
>> about.
>
> I see Eric has posted a fix for skb_try_coalesce(), but is that likely
> to be acceptable for 3.15? How many other similar patches are we
> expecting and/or how long do you think this careful checking will take?
>
> Given that we are now at 3.15-rc5 I think we need to decide how to
> proceed, either push ahead fixing all these issues or (partially) revert
> this netback feature and try again for 3.16.
I guess these problems apply to KVM as well, and it haven't caused them 
problem so far, so I guess the problem shouldn't be that big. I assume 
they are using this feature to send fragmented skbs out from a guest, 
but I might be wrong.
Anyway, I think I'll check tomorrow if there are further places to worry 
about, but I don't think if there are any of them which are easily 
reproducible.

Zoli
