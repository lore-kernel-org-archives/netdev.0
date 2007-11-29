From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] tcp-illinois: incorrect beta usage
Date: Wed, 28 Nov 2007 16:43:31 -0800
Message-ID: <474E0B33.2060108@linux-foundation.org>
References: <aa7d2c6d0711261023m3d2dd850o76a8f44aef022f39@mail.gmail.com>	 <001001c83063$9adbc9d0$d5897e82@csp.uiuc.edu>	 <20071128154725.29af2852@freepuppy.rosehill> <aa7d2c6d0711281625m44bf3ca3me188a7041d3421da@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	shaoliu@princeton.edu, Douglas Leith <doug.leith@nuim.ie>,
	Robert Shorten <robert.shorten@nuim.ie>, netdev@vger.kernel.org
To: Lachlan Andrew <lachlan.andrew@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:35538 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756843AbXK2Aoi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Nov 2007 19:44:38 -0500
In-Reply-To: <aa7d2c6d0711281625m44bf3ca3me188a7041d3421da@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Lachlan Andrew wrote:
> Thanks Stephen.
>
> A related problem (largely due to the published algorithm itself) is
> that Illinois is very aggressive when it over-estimates the maximum
> RTT.
>
> At high load (say 200Mbps and 200ms RTT), a backlog of packets builds
> up just after a loss, causing the RTT estimate to become large.  This
> makes Illinois think that *all* losses are due to corruption not
> congestion, and so only back off by 1/8 instead of 1/2.
>
> I can't think how to fix this except by better RTT estimation, or
> changes to Illinois itself.  Currently, I ignore RTT measurements when
>    sacked_out != 0    and have a heuristic "RTT aging" mechanism, but
> that's pretty ugly.
>
> Cheers,
> Lachlan
>
>   
Ageing the RTT estimates needs to be done anyway.
Maybe something can be reused from H-TCP. The two are closely related.

