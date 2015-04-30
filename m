From: Dave Taht <dave.taht@gmail.com>
Subject: Re: [PATCH net] codel: fix maxpacket/mtu confusion
Date: Thu, 30 Apr 2015 10:01:33 -0700
Message-ID: <CAA93jw4QUyc_hA-TYr4Xqruj4KHUztiE+QP+-9pDtmEvNfH3Tg@mail.gmail.com>
References: <1430412040.3711.94.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Kathleen Nichols <nichols@pollere.com>,
	Van Jacobson <vanj@google.com>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f53.google.com ([209.85.218.53]:34442 "EHLO
	mail-oi0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751077AbbD3RBd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Apr 2015 13:01:33 -0400
Received: by oiko83 with SMTP id o83so52905251oik.1
        for <netdev@vger.kernel.org>; Thu, 30 Apr 2015 10:01:33 -0700 (PDT)
In-Reply-To: <1430412040.3711.94.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I long ago dropped the maxpacket check and the statistic/statistic
collection from various test versions of codel in favor of either a
constant (1500 byte) check or none at all. There is always some level
of buffering underneath codel. I have always wanted the big
GRO/TSO/GRO superpackets to get peeled apart also - the present system
worked OK with ECN in most cases, but seemed  like it could get ugly
if we started dropping 64k worth of superpacket.
