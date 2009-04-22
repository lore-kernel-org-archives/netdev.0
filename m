From: Jesper Dangaard Brouer <hawk@diku.dk>
Subject: Re: [PATCH] Software receive packet steering
Date: Wed, 22 Apr 2009 22:44:41 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0904222156300.21763@ask.diku.dk>
References: <49ED967B.4070105@cosmosbay.com> <20090421084636.198b181e@nehalam>
 <65634d660904211152l6c17aa6dpf7e626474acfe499@mail.gmail.com>
 <20090422.022120.211323498.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-511516320-629505641-1240433081=:21854"
Cc: therbert@google.com, shemminger@vyatta.com,
	Eric Dumazet <dada1@cosmosbay.com>, andi@firstfloor.org,
	netdev <netdev@vger.kernel.org>,
	Robert Olsson <Robert.Olsson@data.slu.se>,
	Jens Laas <jens.laas@ITS.UU.SE>, hawk@comx.dk,
	jens.axboe@oracle.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw2.diku.dk ([130.225.96.92]:59362 "EHLO mgw2.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751173AbZDVUor (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Apr 2009 16:44:47 -0400
In-Reply-To: <20090422.022120.211323498.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---511516320-629505641-1240433081=:21854
Content-Type: TEXT/PLAIN; charset=iso-8859-1; format=flowed
Content-Transfer-Encoding: 8BIT

On Wed, 22 Apr 2009, David Miller wrote:

> One thought I keep coming back to is the hack the block layer
> is using right now.  It remembers which CPU a block I/O request
> comes in on, and it makes sure the completion runs on that
> cpu too.

This is also very important for routing performance.

Experiences from practical 10GbE routing tests (done by Roberts team and 
my self), reveals that we can only achieve (close to) 10Gbit/s routing 
performance when carefully making sure that the rx-queue and tx-queue runs 
on the same CPU. (Not doing so really kills performance).

Currently I'm using some patches by Jens Låås, that allows userspace to 
setup the rx-queue to tx-queues mapping, plus manual smp_affinity tuning. 
The problem with this approach is that it requires way too much manual 
tuning from userspace to achieve good performance.

I would like to see an approach with less manual tuning, as we basically 
"just" need to make sure that TX completion is done on the same CPU as RX. 
I would like to see some effort in this area and is willing to partisipate 
actively.

Cheers,
   Jesper Brouer

--
-------------------------------------------------------------------
MSc. Master of Computer Science
Dept. of Computer Science, University of Copenhagen
Author of http://www.adsl-optimizer.dk
-------------------------------------------------------------------
---511516320-629505641-1240433081=:21854--
