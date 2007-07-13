From: Ranko Zivojnovic <ranko@spidernet.net>
Subject: Re: [NET]: gen_estimator deadlock fix
Date: Fri, 13 Jul 2007 15:26:42 +0300
Message-ID: <1184329602.16732.16.camel@ranko-fc2.spidernet.net>
References: <1184161297.1141.53.camel@ranko-fc2.spidernet.net>
	 <20070712073746.GA1708@ff.dom.local>
	 <1184231903.3477.65.camel@ranko-fc2.spidernet.net>
	 <20070712104641.GB1708@ff.dom.local>
	 <1184240842.3477.110.camel@ranko-fc2.spidernet.net>
	 <46961970.7080209@trash.net>
	 <1184262525.3477.135.camel@ranko-fc2.spidernet.net>
	 <20070713121733.GB3282@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@o2.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from MPP-Goya.spidernet.net ([194.154.128.52]:38705 "EHLO
	mail0pop.spidernet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757008AbXGMM04 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jul 2007 08:26:56 -0400
In-Reply-To: <20070713121733.GB3282@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2007-07-13 at 14:17 +0200, Jarek Poplawski wrote:
> On Thu, Jul 12, 2007 at 08:48:45PM +0300, Ranko Zivojnovic wrote:
> ...
> > Ok - here's the patch for a review - it compiles clean ... and that's as
> > much as it has been tested - I'll try give it a run later today or
> > definitely tomorrow.
> ...
> 
> Ranko, you have some powers!
> 
> Alas, I definitely need more time. I hope I'll manage to check this
> till monday. Of course, if testing will be OK and somebody will check
> and ack this earlier I don't see any reason in waiting on my opinion.

Don't bother - just tested and it is a no-go (it would have been a
wander if it worked from the first time :)) - have to resolve the issues
with qdiscs that do not calculate/use rates...

I'm not sure if it is desirable to have rates available on all qdiscs -
even on pfifo_fast... that way, when you issue...

# tc -s qdisc show dev eth0
qdisc pfifo_fast 0: root bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
 Sent 115971059 bytes 196761 pkt (dropped 0, overlimits 0 requeues 0)
 rate 0bit 0pps backlog 0b 0p requeues 0

...you will not get the 'rate 0bit'.

R.

