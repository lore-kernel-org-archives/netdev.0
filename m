From: Eric Dumazet <edumazet@google.com>
Subject: Re: [REGRESSION, bisect]cxgb4 port failure with TSO traffic after
 commit 10d3be569243def8("tcp-tso: do not split TSO packets at retransmit time")
Date: Fri, 24 Jun 2016 07:25:53 -0700
Message-ID: <CANn89i+ePpSDYPtQeZa=fdN84=4WKdDb88P-dOVyPyY_DMK02g@mail.gmail.com>
References: <6DE8042992C3D3488ACEF3F2607097E3C4A81CA5@nice.asicdesigners.com>
 <CANn89iLpBC5tUqpdSE4jCMKFgUi=mg=2kPZtMaRh-cnBhvauNg@mail.gmail.com> <6DE8042992C3D3488ACEF3F2607097E3C4A82805@nice.asicdesigners.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Hariprasad S <hariprasad@chelsio.com>,
	Casey Leedom <leedom@chelsio.com>,
	Kumar A S <kumaras@chelsio.com>,
	Santosh Rastapur <santosh@chelsio.com>,
	Nirranjan Kirubaharan <nirranjan@chelsio.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"ycheng@google.com" <ycheng@google.com>
To: "Arjun V." <arjun@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f169.google.com ([209.85.161.169]:35930 "EHLO
	mail-yw0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750966AbcFXOZz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jun 2016 10:25:55 -0400
Received: by mail-yw0-f169.google.com with SMTP id b72so101258364ywa.3
        for <netdev@vger.kernel.org>; Fri, 24 Jun 2016 07:25:55 -0700 (PDT)
In-Reply-To: <6DE8042992C3D3488ACEF3F2607097E3C4A82805@nice.asicdesigners.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please do not top post on netdev mailing list

On Fri, Jun 24, 2016 at 4:38 AM, Arjun V. <arjun@chelsio.com> wrote:
> Eric,
> We are seeing skb's with length(skb->len) greater than 65536 coming into our ndo_start_xmit() callback routine.
> We can add a check in our eth_xmit() routine to skip those packets, but it will be better if you fix this in kernel.
>
>
> I have attached pcap file obtained from tcpdump. In the pcap file there are 2 such packets(I used tcpdump filter to extract out those packets).
>
> Let us know if you need anything else.
>

Beats me really.

At retransmit time, we only can eventually reduce packet sizes
(assuming GSO is used, because we might coalesce sub-mss packets in
tcp_retrans_try_collapse())

So why are you seeing too big packets at retransmit, I really have no idea.

MIght be some bug related to MSS computation, overflowing somehow ?
