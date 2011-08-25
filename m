From: Simon Horman <horms@verge.net.au>
Subject: Re: Use of 802.3ad bonding for increasing link throughput
Date: Thu, 25 Aug 2011 18:35:43 +0900
Message-ID: <20110825093540.GB28274@verge.net.au>
References: <4E427499.8060108@cyconix.com>
 <5344.1312998372@death>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tom Brown <sa212+glibc@cyconix.com>,
	netdev <netdev@vger.kernel.org>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:36827 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750827Ab1HYJfs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Aug 2011 05:35:48 -0400
Content-Disposition: inline
In-Reply-To: <5344.1312998372@death>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 10, 2011 at 10:46:12AM -0700, Jay Vosburgh wrote:

[snip]

> 	On linux, the tcp_reordering sysctl value can be raised to
> compensate, but it will still result in increased packet overhead, and
> is not likely to be very efficient, and doesn't help with anything
> that's not TCP/IP.  I have not tested balance-rr in a few years now, but
> my recollection is that, as a best case, throughput of one TCP
> connection could reach about 1.5x with 2 slaves, or about 2.5x with 4
> slaves (where the multipliers are in units of "bandwidth of one slave").

Hi Jay,

for what it is worth I would like to chip in with the results of some
testing I did using ballance-rr and 3 gigabit NICs late last year.  The
link was three direct ("cross-over") cables to a machine that was also
using balance-rr.


I found that by increasing both rx-usecs (from 3 to 45) and enabling GRO
and TSO I was able to push 2.7*10^9 bits/s.

Local CPU utilisation was 30% and remote CPU utilisation was 10%.
Local service demand was 1.7 us/KB and remote service demand was 2.2us/KB.

The MTU was 1500 bytes.

In this configuration, with the tuning options described above, increasing
tcp_reordering (to 127) did not have a noticable effect on throughput but
did increase local CPU utilisation to about 50% and local service demand to
3.0 us/KB.  There was also increased remote CPU utilisation and service
demand, although not as significant.


By using an 9000 byte MTU I was able to get close to 3*10^9 bits/s
with other parameters at their default values.

Local CPU utilisation was 15% and remote CPU utilisation was 5%.
Local service demand was 0.8us/KB and remote service demand was 1.1us/KB.


Increasing rx-usecs was suggested to me by Eric Dumazet on this list.

I no longer have access to the systems that I used to run these tests but I
do have other results that I have omitted from this email for the sake of
brevity.


Anecdotally my opinion after running these and other tests is that if you
want to push more than a  gigabit/s over a single TCP stream then you would
be well advised to get a faster link rather than bond gigabit devices.  I
believe you stated something similar earlier on in this thread.
