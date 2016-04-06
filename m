From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net PATCH v2 2/2] ipv4/GRO: Make GRO conform to RFC 6864
Date: Wed, 06 Apr 2016 09:03:02 -0700
Message-ID: <1459958582.6473.368.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CAKgT0UfcqBUTY1SxawwKdnzS7qW7XggjzpKNcfT3cTSZ9DHMmA@mail.gmail.com>
	 <20160405043209.GA9822@gondor.apana.org.au>
	 <5703D4C5.9060305@solarflare.com>
	 <20160405.194517.431351466693438399.davem@davemloft.net>
	 <5704F156.8030804@solarflare.com>
	 <CALx6S34Sqp7tnmkPRWH0RF_CKrBLLNWFjHbr6Uq2r=6=scMMow@mail.gmail.com>
	 <57051C79.7010303@solarflare.com>
	 <1459957158.6473.363.camel@edumazet-glaptop3.roam.corp.google.com>
	 <57053183.6030002@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <tom@herbertland.com>,
	David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Alex Duyck <aduyck@mirantis.com>,
	Jesse Gross <jesse@kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Edward Cree <ecree@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:32991 "EHLO
	mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750748AbcDFQDG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2016 12:03:06 -0400
Received: by mail-pf0-f172.google.com with SMTP id 184so36530047pff.0
        for <netdev@vger.kernel.org>; Wed, 06 Apr 2016 09:03:04 -0700 (PDT)
In-Reply-To: <57053183.6030002@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-04-06 at 16:55 +0100, Edward Cree wrote:
> On 06/04/16 16:39, Eric Dumazet wrote:
> > Look at the mess of some helpers in net/core/skbuff.c, and imagine the
> > super mess it would be if using a concept of 'super packet with various
> > headers on each segment'.
> Maybe I'm still not explaining this very well, but there is _no_ concept of
> 'super packet [anything]' in this idea.  There is just 'list of skbs that
> were all received in the same NAPI poll, and have not yet been determined to
> be different'.
> 
> Any layer that doesn't want to deal with this stuff will always have the
> option of "while (skb = skb_dequeue(list)) my_normal_receive_function(skb);"
> and in fact I'd make that happen by default for anything that hadn't
> registered a function to take a list.
> > netfilter is already complex, it would become a nightmare.
> A netfilter hook could, for instance, run on each packet in the list, then
> partition the list into sub-lists of packets that all had the same verdict
> (letting go of any that were DROP or STOLEN).  That doesn't seem like it
> should be nightmarish.

Okay, I will let you try this alone ;)
