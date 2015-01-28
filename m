From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [RFC PATCH] net: ipv6: Make address flushing on ifdown optional
Date: Wed, 28 Jan 2015 09:25:59 +0100
Message-ID: <1422433559.4678.15.camel@stressinduktion.org>
References: <1421263039-96198-1-git-send-email-dsahern@gmail.com>
			 <20150122224033.6e2db5ce@urahara>
			 <1422015737.2824.8.camel@stressinduktion.org>
			 <20150127045653.GB13164@gospo.home.greyhouse.net>
		 <1422351861.13969.5.camel@stressinduktion.org>
	 <54C7A6D6.8020805@gmail.com>
	 <1422372523.13969.23.camel@stressinduktion.org>
	 <54C855D6.7050500@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Andy Gospodarek <gospo@cumulusnetworks.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:55019 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757172AbbA1UYc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jan 2015 15:24:32 -0500
Received: from compute1.internal (compute1.nyi.internal [10.202.2.41])
	by mailout.nyi.internal (Postfix) with ESMTP id AFD4C2085E
	for <netdev@vger.kernel.org>; Wed, 28 Jan 2015 03:26:01 -0500 (EST)
In-Reply-To: <54C855D6.7050500@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Di, 2015-01-27 at 20:21 -0700, David Ahern wrote:
> On 01/27/2015 08:28 AM, Hannes Frederic Sowa wrote:
> >>   From the discussion a second patch is needed to make sure DAD is done
> >> on a link up if there is an address configured.
> >
> > Thank you!
> >
> > Let's see if the DAD patch isn't complex, maybe it is a candidate for
> > stable?
> 
> Actually, DAD is done on a link up; you can see the notifications go out 
> when the link is brought up:

Oh, cool, sorry I did not check and misunderstood you in the other mail.

> 18:46:28.519907 IP6 :: > ff02::1:ff00:10: ICMP6, neighbor solicitation, 
> who has 2001:1::10, length 24
> 18:46:28.607650 IP6 :: > ff02::1:ff03:402: ICMP6, neighbor solicitation, 
> who has fe80::1:2ff:fe03:402, length 24
> 
> So current top of tree works fine wrt DAD on addresses added when a link 
> is down and then the link is brought up.
> 
> But, my previous patch does not re-send notifications on the up in a 
> down-up cycle. I believe it is because the IFA_F_TENTATIVE flag is not 
> set for the global address configured. I will address that in the 
> revised patch.

Sounds good, I don't see any more problems with this patch then.

Thanks!
