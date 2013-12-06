From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH net-next] tcp: auto corking
Date: Fri, 06 Dec 2013 13:34:28 -0800
Message-ID: <52A242E4.2090304@hp.com>
References: <1386311765.30495.246.camel@edumazet-glaptop2.roam.corp.google.com> <AE90C24D6B3A694183C094C60CF0A2F6026B7467@saturn3.aculab.com> <52A1F603.2030208@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g6t0187.atlanta.hp.com ([15.193.32.64]:39437 "EHLO
	g6t0187.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752511Ab3LFVeb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Dec 2013 16:34:31 -0500
In-Reply-To: <52A1F603.2030208@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/06/2013 08:06 AM, Rick Jones wrote:
> I was wondering why Nagle didn't catch these things as well.  The
> netperf command line Eric provided though didn't include the
> test-specific -D option that would have disabled Nagle.  At least not
> unless the "super_netperf" wrapper was adding it.
>
> So, why doesn't Nagle catch what is presumably a sub-MSS send while
> there is data outstanding on the connection?

Because this is operating "above" (as it were) Nagle and is looking only 
to try to get the successive small sends into a smaller number of skbs 
yes? So that when there is either no data outstanding, or an MSS's worth 
of data it will be in a small(ish) number of skbs not a long chain of them.

rick jones
