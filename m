From: "Shao Liu" <shaoliu@Princeton.EDU>
Subject: RE: [PATCH] tcp-illinois: incorrect beta usage
Date: Wed, 28 Nov 2007 21:26:12 -0800
Message-ID: <001b01c83248$604f4120$20edc360$@edu>
References: <aa7d2c6d0711261023m3d2dd850o76a8f44aef022f39@mail.gmail.com> <001001c83063$9adbc9d0$d5897e82@csp.uiuc.edu> <20071128154725.29af2852@freepuppy.rosehill> <aa7d2c6d0711281625m44bf3ca3me188a7041d3421da@mail.gmail.com> <474E0B33.2060108@linux-foundation.org>
Reply-To: <shaoliu@Princeton.EDU>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: "'David S. Miller'" <davem@davemloft.net>,
	"'Herbert Xu'" <herbert@gondor.apana.org.au>,
	"'Douglas Leith'" <doug.leith@nuim.ie>,
	"'Robert Shorten'" <robert.shorten@nuim.ie>,
	<netdev@vger.kernel.org>
To: "'Stephen Hemminger'" <shemminger@linux-foundation.org>,
	"'Lachlan Andrew'" <lachlan.andrew@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postoffice03.Princeton.EDU ([128.112.131.174]:62046 "EHLO
	Princeton.EDU" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751071AbXK2Ffb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Nov 2007 00:35:31 -0500
In-Reply-To: <474E0B33.2060108@linux-foundation.org>
Content-Language: en-us
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Stephen and Lachlan,

Thanks for pointing out and fixing this bug.

For the max RTT problem, I have considered it also and I have some idea on
improve it. I also have some other places to improve. I will summarize all
my new ideas and send you an update. For me to change it, could you please
give me a link to download to latest source codes for the whole congestion
control module in Linux implementation, including the general module for all
algorithms, and the implementation for specific algorithms like TCP-Illinois
and H-TCP? 

Thanks for the help!
-Shao



-----Original Message-----
From: Stephen Hemminger [mailto:shemminger@linux-foundation.org] 
Sent: Wednesday, November 28, 2007 4:44 PM
To: Lachlan Andrew
Cc: David S. Miller; Herbert Xu; shaoliu@Princeton.EDU; Douglas Leith;
Robert Shorten; netdev@vger.kernel.org
Subject: Re: [PATCH] tcp-illinois: incorrect beta usage

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


