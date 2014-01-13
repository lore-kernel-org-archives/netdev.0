From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH 1/5] net: mvneta: increase the 64-bit rx/tx stats out of the hot path
Date: Mon, 13 Jan 2014 04:06:51 +0100
Message-ID: <20140113030651.GB18330@1wt.eu>
References: <1389519069-1619-1-git-send-email-w@1wt.eu> <1389519069-1619-2-git-send-email-w@1wt.eu> <1389574192.31367.194.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Gregory CLEMENT <gregory.clement@free-electrons.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:55280 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751110AbaAMDGz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 12 Jan 2014 22:06:55 -0500
Content-Disposition: inline
In-Reply-To: <1389574192.31367.194.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 12, 2014 at 04:49:52PM -0800, Eric Dumazet wrote:
> On Sun, 2014-01-12 at 10:31 +0100, Willy Tarreau wrote:
> > Better count packets and bytes in the stack and on 32 bit then
> > accumulate them at the end for once. This saves two memory writes
> > and two memory barriers per packet. The incoming packet rate was
> > increased by 4.7% on the Openblocks AX3 thanks to this.
> > 
> > Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
> > Cc: Gregory CLEMENT <gregory.clement@free-electrons.com>
> > Signed-off-by: Willy Tarreau <w@1wt.eu>
> > ---
> >  drivers/net/ethernet/marvell/mvneta.c | 15 +++++++++++----
> >  1 file changed, 11 insertions(+), 4 deletions(-)
> 
> 
> Reviewed-by: Eric Dumazet <edumazet@google.com>
> 
> Note that with such a cost, one has to wonder why we keep 64bit stats
> for this NIC on 32bit hosts...

At least this avoids wrapping if stats are not retrieved often enough.
As someone who had to support 32-bit stats in production on a firewall
running on kernel 2.4, I can say it really becomes a problem to graph
activity if stats are not collected as often as every 30 seconds, which
is short in certain environments.

Thanks,
Willy
