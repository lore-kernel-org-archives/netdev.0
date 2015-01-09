From: Jes Sorensen <Jes.Sorensen@redhat.com>
Subject: Re: [PATCH] net: unisys: adding unisys virtnic driver
Date: Fri, 09 Jan 2015 10:44:48 -0500
Message-ID: <wrfjd26o2c27.fsf@redhat.com>
References: <1418842340-29894-1-git-send-email-earfvids@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: benjamin.romer@unisys.com, netdev@vger.kernel.org,
	dzickus@redhat.com, davem@davemloft.net, Bruce.Vessey@unisys.com,
	sparmaintainer@unisys.com, prarit@redhat.com,
	Neil Horman <nhorman@redhat.com>
To: Erik Arfvidson <earfvids@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34434 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757685AbbAIPow (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Jan 2015 10:44:52 -0500
In-Reply-To: <1418842340-29894-1-git-send-email-earfvids@redhat.com> (Erik
	Arfvidson's message of "Wed, 17 Dec 2014 13:52:20 -0500")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Erik Arfvidson <earfvids@redhat.com> writes:
> The purpose of this patch is to add Unisys virtual network driver
> into the network directory and also to start a discussion about
> the requirements needed.
>
> Signed-off-by: Erik Arfvidson <earfvids@redhat.com>

Erik,

I was discussing this with colleagues and I want to give you some
general comments on this. My comments are not specific to virtnic.c
itself.

Looking over the logs of drivers/staging/unisys, I noticed a fair amount
of cleanups has been applied, but not a lot of fixes addressing what I
would consider the real issues.

The first thing you should work on is to get rid of
drivers/staging/unisys/uislib - it looks to provide a lot of wrappers
and utility functions which already exist. You need to address things
like:

 - Custom atomic primitives (uisqueue.c)
 - List handlers (use list.h) and all the utility functions we provide
 - Functions for launching killing kernel threads (uisthread)
 - There is most of a bus implementation in there - is this really
   needed, ie. are the devices sitting on a PCI bus, or is this some
   special bus type?
 - Use proper data types - your code should contain no 'long long' ever!
   If you need data types of a specific size, use u8/u16/u32/u64, and
   please get rid of broken Windows stuff such as BOOL and #pragma.
 - /proc handlers - you should most likely be using /sys
   (configs/debugfs) and don't wrap things in libraries, do it near the
   code using it.

Basically I recommend you start working your way through uislib, and
once you have eliminated 90% of it, you should be a lot closer to code
that can go into mainline.

I know my colleague Neil has some issues on this specific driver, which
I have less insight into, so I think he'll post some comments on that
too.

I hope this is helpful!

Cheers,
Jes
