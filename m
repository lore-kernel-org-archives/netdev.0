From: David Miller <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 11316] New: severe performance regression for
 iptables nat routing
Date: Wed, 13 Aug 2008 19:21:01 -0700 (PDT)
Message-ID: <20080813.192101.221940876.davem@davemloft.net>
References: <bug-11316-10286@http.bugzilla.kernel.org/>
	<20080812221204.46afb4a6.akpm@linux-foundation.org>
	<1218679700.23510.8.camel@2710p.home>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, buytenh@marvell.com,
	netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	kaber@trash.net
To: alex.williamson@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50888
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751386AbYHNCU7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Aug 2008 22:20:59 -0400
In-Reply-To: <1218679700.23510.8.camel@2710p.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alex Williamson <alex.williamson@hp.com>
Date: Wed, 13 Aug 2008 20:08:20 -0600

> git bisect traced the problem back to this changeset:
> 
>         commit e5a4a72d4f88f4389e9340d383ca67031d1b8536
>         Author: Lennert Buytenhek <buytenh@marvell.com>
>         Date:   Sun Aug 3 01:23:10 2008 -0700
>         
>             net: use software GSO for SG+CSUM capable netdevices
> 
> I've verified that I can toggle the slowness by reverting this patch on
> top of 8d0968ab (current head).  The problem is readily reproducible
> using Ubuntu Hardy in a KVM VM with upstream, defconfig kernel.

Patrick I wonder if there a case where iptables NAT will COW the packet
when it really doesn't need to.

It seems, if anything, using GSO should make things go a little bit
faster not slower... Hmmm...

Anyways, if we can't figure this one out soon we can easily revert.
