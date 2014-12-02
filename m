From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: mvneta: fix Tx interrupt delay
Date: Tue, 02 Dec 2014 10:39:49 -0800
Message-ID: <1417545589.5303.75.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20141202071304.GA22512@1wt.eu>
	 <1417522688.5303.35.camel@edumazet-glaptop2.roam.corp.google.com>
	 <547DF2EA.2020908@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Willy Tarreau <w@1wt.eu>, netdev@vger.kernel.org,
	Maggie Mae Roxas <maggie.mae.roxas@gmail.com>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Gregory CLEMENT <gregory.clement@free-electrons.com>
To: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f172.google.com ([209.85.213.172]:40317 "EHLO
	mail-ig0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754007AbaLBSjw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Dec 2014 13:39:52 -0500
Received: by mail-ig0-f172.google.com with SMTP id hl2so15409102igb.17
        for <netdev@vger.kernel.org>; Tue, 02 Dec 2014 10:39:52 -0800 (PST)
In-Reply-To: <547DF2EA.2020908@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-12-02 at 14:12 -0300, Ezequiel Garcia wrote:
> Eric,
> 
> On 12/02/2014 09:18 AM, Eric Dumazet wrote:
> [..]
> > 
> > I am surprised TCP even worked correctly with this problem.
> > 
> > I highly suggest BQL for this driver, now this issue is fixed.
> > 
> 
> Implementing BQL for the mvneta driver was something I wanted to do a
> while ago, but you explained that these kind drivers (i.e. those with
> software TSO) didn't need BQL, because the latency that resulted from
> the ring was too small.
> 
> Quoting (http://www.spinics.net/lists/netdev/msg284439.html):
> ""
> Note that a full size TSO packet (44 or 45 MSS) requires about 88 or 90
> descriptors.
> 
> So I do not think BQL is really needed, because a 512 slots TX ring wont
> add a big latency : About 5 ms max.
> 
> BQL is generally nice for NIC supporting hardware TSO, where a 64KB TSO
> packet consumes 3 or 4 descriptors.
> 
> Also note that TCP Small Queues should limit TX ring occupancy of a
> single bulk flow anyway.
> ""
> 
> Maybe I misunderstood something?

This was indeed the case, but we added recently xmit_more support, and
it uses BQL information. So you might add BQL anyway, if xmit_more
support is useful for this hardware.
