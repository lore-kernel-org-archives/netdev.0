From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: ppp/l2tp doing oversized allocations ?
Date: Sat, 19 May 2012 08:25:30 +0200
Message-ID: <1337408730.7029.69.camel@edumazet-glaptop>
References: <20120514162923.GA4439@redhat.com>
	 <20120519.004652.2261671316587735315.davem@davemloft.net>
	 <1337403685.7029.63.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davej@redhat.com, netdev@vger.kernel.org,
	kernel-team@fedoraproject.org, edumazet@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:63366 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752763Ab2ESGZf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 May 2012 02:25:35 -0400
Received: by weyu7 with SMTP id u7so2201637wey.19
        for <netdev@vger.kernel.org>; Fri, 18 May 2012 23:25:34 -0700 (PDT)
In-Reply-To: <1337403685.7029.63.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2012-05-19 at 07:01 +0200, Eric Dumazet wrote:
> On Sat, 2012-05-19 at 00:46 -0400, David Miller wrote:
> 
> > So it's ESP encapsulated IPSEC over L2tp.
> > 
> > Eric, I wonder if session->hdr_len can take on undesirable values and
> > thus trip up the skb COW'ing calculations you added?
> 
> I take a look, thanks
> 

hdr_len is u16, I have no idea how we can reach MAX_ORDER page
allocations... (more than 2 Mbytes...)

Maybe a memory corruption, or a signed/unsigned mismatch.
