From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] [RFC] allow admin/users to specify rto_min in
 milliseconds rather than jiffies
Date: Thu, 13 Sep 2007 10:39:57 +0200
Message-ID: <20070913103957.5354ea5d@oldman>
References: <200709042020.NAA29612@tardy.cup.hp.com>
	<20070905073801.2f12991b@oldman>
	<46E06E7C.4000407@hp.com>
	<46E84BFA.2070101@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Rick Jones <rick.jones2@hp.com>, netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:58072 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753210AbXIMIjU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Sep 2007 04:39:20 -0400
In-Reply-To: <46E84BFA.2070101@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 12 Sep 2007 13:28:42 -0700
Rick Jones <rick.jones2@hp.com> wrote:

> >> The api in netlink should be in milliseconds rather than compensating
> >> in the application (iproute2).
> > 
> > 
> > My understanding of the in-kernel rtnetlink code is far from complete, 
> > but it doesn't seem to have much in the way of provisions for unit 
> > conversion, which would suggest no nice suffix-based ui as in tc, and ip 
> > is already doing some massaging of units on the display side for a 
> > couple of the other parameters, so I'm at something of a loss.
> 
> So, I used the source and looked and saw that tc seems to convert 
> everything to nanoseconds and passes that to the kernel.  The user can 
> give it seconds, milliseconds, microseconds or nanoseconds by using a 
> suffix. It then does something ostensibly intelligent to display those 
> to the user.
> 
> Ip converts nothing when passing things to the kernel (rtt rttvar or rto 
> - when/if at least the intial rto changes are included - were they?), 
> but when they come-out of the kernel ip converts them to milliseconds. 
>   So the units in != the units out.
> 
> Tc seems much more friendly and less prone to user error.
> 
> I'm still not sure how "easily" rtnetlink can do conversions itself - 
> feedback there would be _very_ welcome - but at the very least, having 
> ip provide at least the illusion of what tc does would seem to be a good 
> thing.
> 
> rick jones

Your observations are correct. rtnetlink can't/shouldn't be doing conversions
itself.  The 'ip' command should use a consistent unit for all values and
do conversions if necessary.
