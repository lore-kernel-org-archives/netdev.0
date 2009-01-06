From: Willy Tarreau <w@1wt.eu>
Subject: Re: Data corruption issue with splice() on 2.6.27.10
Date: Tue, 6 Jan 2009 16:57:15 +0100
Message-ID: <20090106155715.GA28783@1wt.eu>
References: <20081224152841.GB13113@1wt.eu> <20090106085442.GA9513@ff.dom.local> <20090106094138.GE25644@1wt.eu> <20090106100112.GB9513@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jens Axboe <jens.axboe@oracle.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:1132 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751127AbZAFP5c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Jan 2009 10:57:32 -0500
Content-Disposition: inline
In-Reply-To: <20090106100112.GB9513@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 06, 2009 at 10:01:13AM +0000, Jarek Poplawski wrote:
> On Tue, Jan 06, 2009 at 10:41:38AM +0100, Willy Tarreau wrote:
> ...
> > > Great story! Alas I don't understand this fully either, but it seems
> > > Changli Gao was concerned with sendpage sending this "as pages", so
> > > when NETIF_F_SG flag is available. Did you try this without SG btw?
> > 
> > No I did not. I can try, it's not too hard. It would in part defeat the
> > purpose of the mechanism (especially at 10 Gbps) but at least it will
> > help narrow the problem down.
> 
> Yes, I meant it only as a proof of concept. BTW, delaying TCP acks a
> bit for these sendpages should then make it more reproducible, I guess.

OK here is an update. It does not change anything to turn off any acceleration
feature on the interface (tg3) :

root@wtap:~# ethtool -k eth0
Offload parameters for eth0:
rx-checksumming: off
tx-checksumming: off
scatter-gather: off
tcp segmentation offload: off

It still forwards corrupted data like mad. I noticed that the corruption rate
is 10-100 times higher when forwarding from eth0 to eth0 than from eth0 to lo.

Maybe this can help find the culprit ?

Willy

