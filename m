From: Arjun V <arjun@chelsio.com>
Subject: Re: [REGRESSION, bisect]cxgb4 port failure with TSO traffic after
 commit 10d3be569243def8("tcp-tso: do not split TSO packets at retransmit
 time")
Date: Mon, 27 Jun 2016 14:29:58 +0530
Message-ID: <20160627085957.GB13319@v4.asicdesigners.com>
References: <6DE8042992C3D3488ACEF3F2607097E3C4A81CA5@nice.asicdesigners.com>
 <CANn89iLpBC5tUqpdSE4jCMKFgUi=mg=2kPZtMaRh-cnBhvauNg@mail.gmail.com>
 <6DE8042992C3D3488ACEF3F2607097E3C4A82805@nice.asicdesigners.com>
 <CANn89i+ePpSDYPtQeZa=fdN84=4WKdDb88P-dOVyPyY_DMK02g@mail.gmail.com>
 <1466785507.6850.105.camel@edumazet-glaptop3.roam.corp.google.com>
 <20160627071750.GA13304@v4.asicdesigners.com>
 <1467014782.6850.144.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <edumazet@google.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Hariprasad S <hariprasad@chelsio.com>,
	Casey Leedom <leedom@chelsio.com>,
	Kumar A S <kumaras@chelsio.com>,
	Santosh Rastapur <santosh@chelsio.com>,
	Nirranjan Kirubaharan <nirranjan@chelsio.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"ycheng@google.com" <ycheng@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [12.32.117.8] ([12.32.117.8]:44190 "EHLO
	stargate3.asicdesigners.com" rhost-flags-FAIL-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751671AbcF0JBR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jun 2016 05:01:17 -0400
Content-Disposition: inline
In-Reply-To: <1467014782.6850.144.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday, June 06/27/16, 2016 at 13:36:22 +0530, Eric Dumazet wrote:
> On Mon, 2016-06-27 at 12:47 +0530, Arjun V wrote:
> 
> > Eric,
> > 
> > Thanks for the quick patch. It didn't help much. We still see packets larger than 65536 with the patch.
> > 
> > Below is the dump_stack() trace I am seeing for packets larger than 65536 in our xmit routine:
> 
> What values do you get for skb->len ?
>
These are the skb->len values I am hitting in t4_eth_xmit() for around half hour run of netperf bidi(800 connections total)
packet with skb->len 69570 detected
packet with skb->len 66674 detected
packet with skb->len 68122 detected
packet with skb->len 68122 detected
packet with skb->len 72466 detected
packet with skb->len 76810 detected
packet with skb->len 69570 detected
packet with skb->len 66674 detected
packet with skb->len 66674 detected
packet with skb->len 68122 detected
packet with skb->len 71018 detected
packet with skb->len 66674 detected
packet with skb->len 66674 detected
packet with skb->len 66674 detected
packet with skb->len 69570 detected
packet with skb->len 68122 detected
packet with skb->len 73914 detected
packet with skb->len 66674 detected
packet with skb->len 69570 detected
packet with skb->len 69570 detected
packet with skb->len 69570 detected
packet with skb->len 68122 detected
packet with skb->len 72466 detected
packet with skb->len 68122 detected
packet with skb->len 69570 detected
packet with skb->len 69570 detected
packet with skb->len 72466 detected
packet with skb->len 72466 detected

> Again, at retransmit time we never grow packets, we only can split
> existing packets. So there is something very wrong.
> 
> The original xmit should already have hit this issue.
> 
> 
> 
