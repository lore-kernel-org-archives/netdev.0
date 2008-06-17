From: David Miller <davem@davemloft.net>
Subject: Re: [TCP]: TCP_DEFER_ACCEPT causes leak sockets
Date: Tue, 17 Jun 2008 00:38:32 -0700 (PDT)
Message-ID: <20080617.003832.130616157.davem@davemloft.net>
References: <20080613114746.GA27811@elte.hu>
	<20080616.165900.189566405.davem@davemloft.net>
	<20080617072658.GA12535@elte.hu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, vgusev@openvz.org, mcmanus@ducksong.com,
	xemul@openvz.org, netdev@vger.kernel.org,
	ilpo.jarvinen@helsinki.fi, linux-kernel@vger.kernel.org
To: mingo@elte.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42242
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753509AbYFQHib (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2008 03:38:31 -0400
In-Reply-To: <20080617072658.GA12535@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ingo Molnar <mingo@elte.hu>
Date: Tue, 17 Jun 2008 09:26:58 +0200

> So since there's no clear bug pattern and no sure reproducability on my 
> side i'd suggest we track this problem separately and "do nothing" right 
> now. I've excluded this warning from my 'is the freshly booted kernel 
> buggy' list of conditions of -tip testing so it's not holding me up.

I'm going to push the revert through just to be safe and I think it's
a good idea to do so because all of those defer accept changes should
be resubmitted as a group for 2.6.27

> and i can apply any test-patch if that would be helpful - if it does a 
> WARN_ON() i'll notice it. (pure extra debug printks with no stack trace 
> are much harder to notice in automated tests)

I don't have time to work on your bug, sorry.  Someone else will
have to step forward and help you with it.

FWIW I don't think your TX timeout problem has anything to do with
packet ordering.  The TX element of the network device is totally
stateless, but it's hanging under some set of circumstances to the
point where we timeout and reset the hardware to get it going again.
