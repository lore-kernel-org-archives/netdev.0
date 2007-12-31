From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/4] New interface for memory accounting (take 1)
Date: Sun, 30 Dec 2007 23:34:13 -0800 (PST)
Message-ID: <20071230.233413.117211235.davem@davemloft.net>
References: <47775B25.7020401@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, vladislav.yasevich@hp.com,
	netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net,
	tyasui@redhat.com, mhiramat@redhat.com,
	satoshi.oshima.fk@hitachi.com, billfink@mindspring.com,
	andi@firstfloor.org, johnpol@2ka.mipt.ru,
	shemminger@linux-foundation.org, yoshfuji@linux-ipv6.org,
	yumiko.sugita.yf@hitachi.com
To: haoki@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42233
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755943AbXLaHeO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Dec 2007 02:34:14 -0500
In-Reply-To: <47775B25.7020401@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hideo AOKI <haoki@redhat.com>
Date: Sun, 30 Dec 2007 03:47:33 -0500

> Hello,
> 
> This patch set introduces new memory accounting interface.
> Current interface is written for stream protocols only.
> To enable memory accounting in other protocols (e.g. UDP),
> I enhanced the interface and updated TCP and SCTP memory
> accounting.
> 
> The patch set consists of the following 4 patches.
> 
> [1/4] introducing new memory accounting interface
> [2/4] adding memory accounting points to consolidate functions
> [3/4] updating TCP to use new interface
> [4/4] updating SCTP to use new interface
> 
> The patch set was tested on net-2.6.25 tree.

I like this work very much and will add this to net-2.6.25
But I will have to combine it all into one patch.

You cannot have one patch which breaks the build in any way.  All of
the kernel must build properly after each patch in your patchset is
applied.

Since patch 1 renames all of the sk_stream_*() functions, TCP and SCTP
stop building.

We enforce this rule, otherwise when users try to use "git bisect" to
find out where regressions are added, they will get stuck in places
like this where the tree will not build due to such careless
changesets.

Thank you.
