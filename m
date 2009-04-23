From: Jens Laas <jens.laas@its.uu.se>
Subject: Re: [PATCH] Software receive packet steering
Date: Thu, 23 Apr 2009 11:12:49 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0904231036400.4832@jens.its.uu.se>
References: <49ED967B.4070105@cosmosbay.com> <20090421084636.198b181e@nehalam>
 <65634d660904211152l6c17aa6dpf7e626474acfe499@mail.gmail.com>
 <20090422.022120.211323498.davem@davemloft.net> <Pine.LNX.4.64.0904222156300.21763@ask.diku.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=iso-8859-1;
	FORMAT=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, therbert@google.com,
	shemminger@vyatta.com, Eric Dumazet <dada1@cosmosbay.com>,
	andi@firstfloor.org, netdev <netdev@vger.kernel.org>,
	Robert Olsson <Robert.Olsson@data.slu.se>,
	Jens Laas <jens.laas@ITS.UU.SE>, hawk@comx.dk,
	jens.axboe@oracle.com
To: Jesper Dangaard Brouer <hawk@diku.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atthis.its.uu.se ([130.238.7.58]:52990 "EHLO atthis.its.uu.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752284AbZDWJQJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Apr 2009 05:16:09 -0400
In-Reply-To: <Pine.LNX.4.64.0904222156300.21763@ask.diku.dk>
Content-ID: <Pine.LNX.4.64.0904231036402.4832@jens.its.uu.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(09.04.22 kl.22:44) Jesper Dangaard Brouer skrev f=F6ljande till David =
Miller:

> On Wed, 22 Apr 2009, David Miller wrote:
>
>> One thought I keep coming back to is the hack the block layer
>> is using right now.  It remembers which CPU a block I/O request
>> comes in on, and it makes sure the completion runs on that
>> cpu too.
>
> This is also very important for routing performance.
>
> Experiences from practical 10GbE routing tests (done by Roberts team =
and my=20
> self), reveals that we can only achieve (close to) 10Gbit/s routing=20
> performance when carefully making sure that the rx-queue and tx-queue=
 runs on=20
> the same CPU. (Not doing so really kills performance).
>
> Currently I'm using some patches by Jens L=E5=E5s, that allows usersp=
ace to setup=20
> the rx-queue to tx-queues mapping, plus manual smp_affinity tuning. T=
he=20
> problem with this approach is that it requires way too much manual tu=
ning=20
> from userspace to achieve good performance.

We have a C-program for setting the affinity correctly. Note that=20
"correctly" very much depends on your setup and what you want to do.
We started with a script for doing this, but its a bit easier to implem=
ent=20
some heuristics in a proper program.

The patch (which implements a concept called "flowtrunks") also require=
s=20
setup from userspace (via ethtool ioctl). We dont actually use this yet=
 in=20
production.

The natural way to go forward would be to implement in userspace a prog=
ram=20
that can tune smp_affinity and queue-mapping (maybe via flowtrunks)=20
together. With knowledge of the setup and userpreference this should be=
=20
doable to automatically tune your system for you.

One advantage with flowtrunks (generic queue/nic to/from flowtrunk=20
mapping) would be for us to not have to patch every supported nic.
Plus we could tune the system for more than one usecase (forwarding=20
between multi-queue nics).
The main object of the flowtrunk patch was to try to start a discussion=
=20
and create something concrete to help our thinking.=20
This problem-space needs to be explored.

>
> I would like to see an approach with less manual tuning, as we basica=
lly=20
> "just" need to make sure that TX completion is done on the same CPU a=
s RX. I=20
> would like to see some effort in this area and is willing to partisip=
ate=20
> actively.

I dont see a problem with tuning from userspace. I think it will be har=
d=20
for the kernel to automatically tune all types of setups for all usecas=
es.=20
Maybe Im just lacking in imagination though.

Cheers,
Jens

>
> Cheers,
>  Jesper Brouer
>
> --
> -------------------------------------------------------------------
> MSc. Master of Computer Science
> Dept. of Computer Science, University of Copenhagen
> Author of http://www.adsl-optimizer.dk
> -------------------------------------------------------------------

-----------------------------------------------------------------------
     'In theory, there is no difference between theory and practice.
      But, in practice, there is.'
-----------------------------------------------------------------------
     Jens L=E5=E5s                              Email: jens.laas@its.uu=
=2Ese
     ITS                                    Phone: +46 18 471 77 03
     SWEDEN
-----------------------------------------------------------------------
