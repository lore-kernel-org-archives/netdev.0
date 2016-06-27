From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [REGRESSION, bisect]cxgb4 port failure with TSO traffic after
 commit 10d3be569243def8("tcp-tso: do not split TSO packets at retransmit
 time")
Date: Mon, 27 Jun 2016 10:06:22 +0200
Message-ID: <1467014782.6850.144.camel@edumazet-glaptop3.roam.corp.google.com>
References: <6DE8042992C3D3488ACEF3F2607097E3C4A81CA5@nice.asicdesigners.com>
	 <CANn89iLpBC5tUqpdSE4jCMKFgUi=mg=2kPZtMaRh-cnBhvauNg@mail.gmail.com>
	 <6DE8042992C3D3488ACEF3F2607097E3C4A82805@nice.asicdesigners.com>
	 <CANn89i+ePpSDYPtQeZa=fdN84=4WKdDb88P-dOVyPyY_DMK02g@mail.gmail.com>
	 <1466785507.6850.105.camel@edumazet-glaptop3.roam.corp.google.com>
	 <20160627071750.GA13304@v4.asicdesigners.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Hariprasad S <hariprasad@chelsio.com>,
	Casey Leedom <leedom@chelsio.com>,
	Kumar A S <kumaras@chelsio.com>,
	Santosh Rastapur <santosh@chelsio.com>,
	Nirranjan Kirubaharan <nirranjan@chelsio.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"ycheng@google.com" <ycheng@google.com>
To: Arjun V <arjun@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:35222 "EHLO
	mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751664AbcF0IGa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jun 2016 04:06:30 -0400
Received: by mail-wm0-f65.google.com with SMTP id a66so22349696wme.2
        for <netdev@vger.kernel.org>; Mon, 27 Jun 2016 01:06:29 -0700 (PDT)
In-Reply-To: <20160627071750.GA13304@v4.asicdesigners.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-06-27 at 12:47 +0530, Arjun V wrote:

> Eric,
> 
> Thanks for the quick patch. It didn't help much. We still see packets larger than 65536 with the patch.
> 
> Below is the dump_stack() trace I am seeing for packets larger than 65536 in our xmit routine:

What values do you get for skb->len ?

Again, at retransmit time we never grow packets, we only can split
existing packets. So there is something very wrong.

The original xmit should already have hit this issue.
