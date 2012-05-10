From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Fwd: Memory exhaust issue with only IPsec policies configured
 on continuous traffic
Date: Thu, 10 May 2012 07:27:07 +0200
Message-ID: <1336627627.12504.127.camel@edumazet-glaptop>
References: <F0B93D0554724543876B9A180DC988575B8867@039-SN1MPN1-001.039d.mgd.msft.net>
	 <CAETiZ-QTWN2U=hmaCS39Q8hzNysjam+eS5FSi-EYO7cXtTbGKQ@mail.gmail.com>
	 <CAETiZ-QvamMJxfGJDK4CiKngELNevmOXnh7M=UGnkH61XrT5dw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au, benjamin.thery@bull.net,
	davem@davemloft.net, pstaszewski@itcare.pl
To: Nikhil Agarwal <hi2nikhil@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:40525 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752781Ab2EJF1N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 May 2012 01:27:13 -0400
In-Reply-To: <CAETiZ-QvamMJxfGJDK4CiKngELNevmOXnh7M=UGnkH61XrT5dw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-05-10 at 10:53 +0530, Nikhil Agarwal wrote:
> Hi All,
> 
> Can you please help on this?

Dont top post please

> 
> -----Original Message-----
> From: Agarwal Nikhil-B38457
> Sent: Wednesday, May 09, 2012 2:53 PM
> To: linux-kernel@vger.kernel.org; netdev@vger.kernel.org
> Subject: Memory exhaust issue with only IPsec policies configured on
> continuous traffic
> 
> Hi all,
>                In a typical scenario, when IPSEC policies are
> configured in the system but SA is not present or negotiation fails or
> IKE daemon is not running.  The current behavior of xfrm is to send
> those matching packets to blackhole route.  i.e. xfrm_bundle_lookup
> returns a bundle with null route and xfrm_lookup returns a blackhole
> route.
> 
> For each of these packet a dst_alloc is called in
> ipv4_blackhole_route. However when these skbs get free and their dst's
> get discarded using dst_free and the garbage collector is scheduled
> using cancel_delayed_work and schedule_delayed_work.
> 
> If the packets are coming continuously garbage collector may not get
> scheduled and large amount of memory is stuck to be freed causing the
> system to go into non-recoverable state.
> 
> Any ideas?

Yep, we can use DST_NOCACHE
