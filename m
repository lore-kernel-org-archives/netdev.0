From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [REGRESSION, bisect]cxgb4 port failure with TSO traffic after
 commit 10d3be569243def8("tcp-tso: do not split TSO packets at retransmit
 time")
Date: Mon, 27 Jun 2016 12:50:17 +0200
Message-ID: <1467024617.6850.148.camel@edumazet-glaptop3.roam.corp.google.com>
References: <6DE8042992C3D3488ACEF3F2607097E3C4A81CA5@nice.asicdesigners.com>
	 <CANn89iLpBC5tUqpdSE4jCMKFgUi=mg=2kPZtMaRh-cnBhvauNg@mail.gmail.com>
	 <6DE8042992C3D3488ACEF3F2607097E3C4A82805@nice.asicdesigners.com>
	 <CANn89i+ePpSDYPtQeZa=fdN84=4WKdDb88P-dOVyPyY_DMK02g@mail.gmail.com>
	 <1466785507.6850.105.camel@edumazet-glaptop3.roam.corp.google.com>
	 <20160627071750.GA13304@v4.asicdesigners.com>
	 <1467014782.6850.144.camel@edumazet-glaptop3.roam.corp.google.com>
	 <20160627085957.GB13319@v4.asicdesigners.com>
	 <1467019279.6850.145.camel@edumazet-glaptop3.roam.corp.google.com>
	 <20160627095445.GC13319@v4.asicdesigners.com>
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
Received: from mail-wm0-f68.google.com ([74.125.82.68]:35161 "EHLO
	mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751784AbcF0KuY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jun 2016 06:50:24 -0400
Received: by mail-wm0-f68.google.com with SMTP id a66so23435561wme.2
        for <netdev@vger.kernel.org>; Mon, 27 Jun 2016 03:50:24 -0700 (PDT)
In-Reply-To: <20160627095445.GC13319@v4.asicdesigners.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-06-27 at 15:24 +0530, Arjun V wrote:

> Applied your patch.
> The above debug print is not getting invoked, when skb->len is greater than 65536.

Interesting.

It looks like we might have a bug in tcp_shift_skb_data() not respecting
sk->sk_gso_max_size at all ...

I will send a patch.

Thanks.
