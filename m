From: Jens Axboe <jens.axboe@oracle.com>
Subject: Re: [PATCH] Software receive packet steering
Date: Thu, 23 Apr 2009 08:58:30 +0200
Message-ID: <20090423065830.GN4593@kernel.dk>
References: <49ED967B.4070105@cosmosbay.com> <20090421084636.198b181e@nehalam> <65634d660904211152l6c17aa6dpf7e626474acfe499@mail.gmail.com> <20090422.022120.211323498.davem@davemloft.net> <Pine.LNX.4.64.0904222156300.21763@ask.diku.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, therbert@google.com,
	shemminger@vyatta.com, Eric Dumazet <dada1@cosmosbay.com>,
	andi@firstfloor.org, netdev <netdev@vger.kernel.org>,
	Robert Olsson <Robert.Olsson@data.slu.se>,
	Jens Laas <jens.laas@ITS.UU.SE>, hawk@comx.dk
To: Jesper Dangaard Brouer <hawk@diku.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from brick.kernel.dk ([93.163.65.50]:33569 "EHLO kernel.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751631AbZDWG6c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Apr 2009 02:58:32 -0400
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0904222156300.21763@ask.diku.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 22 2009, Jesper Dangaard Brouer wrote:
> On Wed, 22 Apr 2009, David Miller wrote:
>
>> One thought I keep coming back to is the hack the block layer
>> is using right now.  It remembers which CPU a block I/O request
>> comes in on, and it makes sure the completion runs on that
>> cpu too.

Hack?! :-)

It's actually nicely integrated to our existing IO completion path,
where we raise a softirq to complete the IO out of path. The only
difference now being that if you enable rq_affinity, it'll raise the
softirq potentially on a remote CPU except of always using the local
one.

> This is also very important for routing performance.
>
> Experiences from practical 10GbE routing tests (done by Roberts team =
and
> my self), reveals that we can only achieve (close to) 10Gbit/s routin=
g
> performance when carefully making sure that the rx-queue and tx-queue=
 runs
> on the same CPU. (Not doing so really kills performance).
>
> Currently I'm using some patches by Jens L=E5=E5s, that allows usersp=
ace to
> setup the rx-queue to tx-queues mapping, plus manual smp_affinity tun=
ing.
> The problem with this approach is that it requires way too much manua=
l
> tuning from userspace to achieve good performance.
>
> I would like to see an approach with less manual tuning, as we basica=
lly
> "just" need to make sure that TX completion is done on the same CPU a=
s RX.
> I would like to see some effort in this area and is willing to partis=
ipate
> actively.

I saw very nice benefits on the IO side as well!

--=20
Jens Axboe

