From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH 10/13] tg3: Increase the PCI MRRS
Date: Thu, 15 Nov 2007 15:51:31 -0800
Message-ID: <1195170691.5745.10.camel@dell>
References: <1194655141.5745.272.camel@teletran1>
 <20071112.212135.172019737.davem@davemloft.net>
 <1195165211.20497.107.camel@teletran1>
 <20071115.144103.24280158.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: mcarlson@broadcom.com, "netdev" <netdev@vger.kernel.org>,
	andy@greyhouse.net
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3918 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755180AbXKOXB4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Nov 2007 18:01:56 -0500
In-Reply-To: <20071115.144103.24280158.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2007-11-15 at 14:41 -0800, David Miller wrote:
> From: "Matt Carlson" <mcarlson@broadcom.com>
> Date: Thu, 15 Nov 2007 14:20:10 -0800
> >
> > Keeping the MRRS at 512 introduces DMA latencies that effectively
> > prevent us from achieving linerate.  With a packet size of ~1.5K and the
> > MRRS at 512 bytes, the DMA will be broken into at least 3 DMA reads.
> > Each DMA read takes ~1usec to initiate.  It is this overhead that starts
> > to cut into total throughput.
> 
> Ok, but wouldn't every networking device on PCI need to do this then?

No, it depends on the design.  For example, a bigger maximum payload
size will alleviate the problem (tg3 hardware is using 128).  Multiple
DMA read channels to pipeline the multiple read requests will also help.

We don't need to increase the MRRS on bnx2 hardware to get line-rate,
for example.

> 
> I want to hear what you think about this wrt. what I mentioned about
> fairness above.  What's the point of PCI specifying a limit to comply
> with if nobody complies with the limit for localized performance
> reasons?

Fairness is harder to know because it depends on chipset behavior.  PCIE
is not shared so there's no fairness issue at the local PCIE.  Any
fairness issue will be at the bridge.

I don't know what's the exact rationale for defaulting to 512, but I
will try to find out.

> 
> I think this is an important issue.  Someone down the road is going to
> see bad disk throughput when doing lots of network transfers and
> wonder why that is.  It will be hard to debug, but it won't be
> difficult for us to do something proactive about this right now to
> prevent that problem from happening in the first place.
> 
> Thanks.
> 

