From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] inet: dont set inet_rcv_saddr in connect()
Date: Tue, 07 Sep 2010 22:36:54 -0700 (PDT)
Message-ID: <20100907.223654.70187707.davem@davemloft.net>
References: <1283895316.2634.248.camel@edumazet-laptop>
	<4C86F653.6070707@hp.com>
	<1283921857.2634.747.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: brian.haley@hp.com, ole@ans.pl, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52644
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755653Ab0IHFgg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Sep 2010 01:36:36 -0400
In-Reply-To: <1283921857.2634.747.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 08 Sep 2010 06:57:37 +0200

>    Document that connect() also sets local address, and that before
> doing a second connect() to change remote address, its mandatory to
> first issue a connect(AF_UNSPEC) to clear local address (if not locked
> by a prior bind() call)

For connectionless sockets, the application may connect() as many
times as it wishes to change the remote address.  The local address
remains set if it were set before such a re-associating connect().

It need only issue a connect(AF_UNSPEC) to make the socket have no
remote association, and as you state this operation will also wipe out
any local address settings not created by a bind() call.

And nicely our man pages are very clear about this :-) as is BSD and
Steven's volume 2.

This has been legal for decades, so we have to keep working this way.
