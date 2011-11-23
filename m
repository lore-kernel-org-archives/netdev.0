From: Dave Taht <dave.taht@gmail.com>
Subject: Re: [PATCH v3 01/10] dql: Dynamic queue limits
Date: Wed, 23 Nov 2011 18:27:47 +0100
Message-ID: <CAA93jw5Mopc8E7MPFrKDNz0eBAwskW-2iGz0n=qBbmTfhT7ejg@mail.gmail.com>
References: <alpine.DEB.2.00.1111222138280.13686@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:44939 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751198Ab1KWR1s convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2011 12:27:48 -0500
Received: by vcbfk14 with SMTP id fk14so567998vcb.19
        for <netdev@vger.kernel.org>; Wed, 23 Nov 2011 09:27:47 -0800 (PST)
In-Reply-To: <alpine.DEB.2.00.1111222138280.13686@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 23, 2011 at 6:52 AM, Tom Herbert <therbert@google.com> wrot=
e:
> Implementation of dynamic queue limits (dql). =A0This is a libary whi=
ch
> allows a queue limit to be dynamically managed. =A0The goal of dql is
> to set the queue limit, number of objects to the queue, to be minimiz=
ed
> without allowing the queue to be starved.

Dear Tom:

I have been fiddling with v3 of your patch series for much of the day,
artificially imposing 10Mbit and 100Mbit limits on the network with
ethtool.

The performance of multiple tcp streams 'feels' quite good across
multiple, saturating workloads over the LFN, and short distances, but
the data I collected today was too muddled and confusing to publish.

I need to finish patching this into a couple other boxes before
rebuilding the testbed,
and judging from the code review comments it would seem a good idea to
wait for another go-round.

I did a build on top of commit b4bbb02934e4511d9083f15c23e90703482e84ad

for ubuntu here:

http://huchra.bufferbloat.net/~d/bql/

the usual caveats apply to development kernels... I ran all day without=
 a crash,
testing the e1000e driver, the qfq qdisc, red, and sfq.

two drivers (forcedeth, bnx2x_) did not apply on top of that commit.

If anyone cares, here are also the various QFQ + RED scheduler scripts
I've been fiddling with. These seemed to help at 100Mbit, in the
previous series.

https://github.com/dtaht/deBloat/blob/master/wip/

eqfq (pure qfq), eqfq.red and eqfq.red.10mbit are the only three
seriously tested at the moment.

Would love to know what/how qfq does to cpu at a gigabit (some red
tuning would be needed on top of the script) on a machine that can
drive it, now that there's drivers that stop gobbling packets so
greedily...
