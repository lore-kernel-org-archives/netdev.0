From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [WIP][PATCHES] Network xmit batching
Date: Tue, 19 Jun 2007 17:21:48 +0400
Message-ID: <20070619132148.GA32078@2ka.mipt.ru>
References: <OFB311484E.057E34E9-ON652572F3.001D5838-652572F3.0022766D@in.ibm.com> <1181216629.4064.22.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: Krishna Kumar2 <krkumar2@in.ibm.com>,
	Gagan Arneja <gaagaan@gmail.com>, netdev@vger.kernel.org,
	Rick Jones <rick.jones2@hp.com>,
	Sridhar Samudrala <sri@us.ibm.com>,
	David Miller <davem@davemloft.net>,
	Robert Olsson <Robert.Olsson@data.slu.se>
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:40188 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753305AbXFSOPe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Jun 2007 10:15:34 -0400
Content-Disposition: inline
In-Reply-To: <1181216629.4064.22.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi.

On Thu, Jun 07, 2007 at 07:43:49AM -0400, jamal (hadi@cyberus.ca) wrote:
> Folks, we need help. Please run this on different hardware. Evgeniy, i
> thought this kind of stuff excites you, no? ;-> (wink, wink).
> Only the sender needs the patch but the receiver must be a more powerful
> machine (so that it is not the bottleneck).

I've ran several simple tests with desktop e1000 adapter I managed to
find.

Test machine is amd athlon64 3500+ with 1gb of ram.
Another point is dektop core duo 3.4 ghz with 2 gb of ram and sky2
driver.

Simple test included test -> desktop and vice versa traffic with 128 and
4096 block size in netperf-2.4.3 setup.

Test machine runs 2.6.22-rc5-batch and mainline tree (there is a test
with 2.6.22-rc4 and there is a noticeble performance win compared to
that tree in the latest git, likely tcp congestion changes resulted in
better utilisation). Batched xmit has better numbers.

Results:

2.6.20-ubuntu -> test machine

2.6.22-rc4-batch:
128: 725.43 724.14
4096: 698.63 712.77

2.6.22-rc5-mainline:
128: 760.91 762.04
4096: 784.32 788.53

2.6.22-rc5-batch:
128: 766.70
4096: 788.24


test machine -> 2.6.20-ubuntu

2.6.22-rc5-mainline:
128: 558.16 (Desired confidence was not achieved within the specified iterations.)
4096: 814.01

2.6.22-rc5-batch:
128: 569.14 (Desired confidence was not achieved within the specified iterations.)
4096: 822.72


-- 
	Evgeniy Polyakov
