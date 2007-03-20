From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: 2.6.20.3-rc1 / iproute2 hoplimit 2^32-1 vs 2^8-1
Date: Tue, 20 Mar 2007 09:39:49 +0100 (CET)
Message-ID: <20070320.093949.117333367.yoshfuji@linux-ipv6.org>
References: <45FEABE1.9050003@trash.net>
	<20070319.121844.112623702.davem@davemloft.net>
	<Pine.LNX.4.64.0703201026300.25136@netcore.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, kaber@trash.net, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: pekkas@netcore.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:35006 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753535AbXCTIjM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Mar 2007 04:39:12 -0400
In-Reply-To: <Pine.LNX.4.64.0703201026300.25136@netcore.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <Pine.LNX.4.64.0703201026300.25136@netcore.fi> (at Tue, 20 Mar 2007 10:27:51 +0200 (EET)), Pekka Savola <pekkas@netcore.fi> says:

> On Mon, 19 Mar 2007, David Miller wrote:
> > From: Patrick McHardy <kaber@trash.net>
> > Date: Mon, 19 Mar 2007 16:27:29 +0100
> >
> >> Mhh actually this looks intentional:
> >>
> >> icmpv6_send and some other output functions do:
> >> 	int hlimit;
> >> ...
> >>         if (hlimit < 0)
> >>                 hlimit = dst_metric(dst, RTAX_HOPLIMIT);
> >>         if (hlimit < 0)
> >>                 hlimit = ipv6_get_hoplimit(dst->dev);
> >
> > Yep, negative value has a specific meaning.
> 
> Which seems to indicate that the kernel-internal implementation has a 
> need to store a negative TTL.  Reporting it to the userspace as a 
> negative doesn't seem right though?

I think it is better to fix iproute2 instead, 1) to treat the variable as 
int, or, 2) not to show such variable.

--yoshfuji
