From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH][BUG] tcp: advertise MSS requested by user
Date: Sat, 13 Jun 2009 12:12:31 +0200
Message-ID: <20090613101231.GA11885@1wt.eu>
References: <48B44768.3030208@gmail.com> <20080921.002215.70489510.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: virtualphtn@gmail.com, netdev@vger.kernel.org,
	lachlan.andrew@gmail.com, stable@kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:35815 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753223AbZFMKNA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 13 Jun 2009 06:13:00 -0400
Content-Disposition: inline
In-Reply-To: <20080921.002215.70489510.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

On Sun, Sep 21, 2008 at 12:22:15AM -0700, David Miller wrote:
> From: Tom Quetchenbach <virtualphtn@gmail.com>
> Date: Tue, 26 Aug 2008 11:11:52 -0700
> 
> > This patch (applies to latest net-2.6) reduces the advertised value to
> > that requested by the user as long as setsockopt() is called before
> > connect() or accept(). This seems like the behavior that one would expect
> > as well as that which is documented.
>  ...
> > Signed-off-by: Tom Quetchenbach <virtualphtn@gmail.com>
> 
> I've applied this patch to net-next-2.6, thanks Tom.

Yesterday I worked on a similar patch to address the same issue which
I was experiencing on 2.6.27.25. Before posting my tiny patch, I
preferred to check the list and found this one which addresses the
same issue and which is already merged in mainline !

Would you accept to queue it for -stable please ? The commit ID was
f5fff5dc8a7a3f395b0525c02ba92c95d42b7390. I did not figure how to find
when it was merged, because its version pre-dates 2.6.27 (it matches
your net-2.6 queue I think). git-describe --contains tells me it was
merged in 2.6.28-rc1.

BTW, I found the same behaviour in 2.4 too, and from my quick analysis,
the mss is correctly computed till the moment the SYN-ACK is built,
where the one from the route cache is used instead. I'll check deeper
when I have time, but most likely a similar fix is needed there too.

Thanks!
Willy

