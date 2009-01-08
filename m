From: Denys Fedoryschenko <denys@visp.net.lb>
Subject: Re: HTB - very bad precision? HFSC works fine! 2.6.28
Date: Thu, 8 Jan 2009 11:34:41 +0200
Message-ID: <200901081134.41467.denys@visp.net.lb>
References: <20090108092720.GC4496@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:49401 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751132AbZAHJed (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2009 04:34:33 -0500
In-Reply-To: <20090108092720.GC4496@ff.dom.local>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I will check all this things, as soon as traffic reach peak (after 6 hours i 
think).

I cannot reverse to old kernel, but it looks like previous kernel was not much 
better. But sadly i cannot say for sure. I think previous kernels had issue, 
because i had to move to HFSC on our satellite backbone from HTB in 2.6.25, 
because it is very sensitive to shaping precision. But there i didn't had 
access to switch, to be sure it is shaping precision issue or something else.

On Thursday 08 January 2009 11:27:20 Jarek Poplawski wrote:
> On 07-01-2009 23:02, Denys Fedoryschenko wrote:
> > I notice that our uplink ISP complaining, that we are exceeding our UP
> > rate.
> >
> > I have configured at HTB 60Mbps, but he is actually receiving bursts up
> > to 64Mbps.
> >
> > I tried to lower down HTB values to 57Mbps, and even on Cisco switch
> > interface counter(it is averaging 30 seconds of data i guess, to
> > calculate bandwidth) - it shows 60.1 - 60.4.
> >
> > Funny thing, root class in HTB shows 57.1 - 57.3 Mbps. So maybe byte
> > counting is wrong in HTB?
>
> Does this "2.6.28" in the subject mean it was better before or not
> tested? Could you do a few snapshots with: tc -s qdisc show dev $DEV
>
> > I have also "default filter"
> > tc filter add dev ${DEV} parent 1:0 protocol ip prio 800 u32 match ip src
> > 0.0.0.0/0 flowid 1:50
>
> I can see "tc qdisc add ... default 1000" in your config; is there a
> class with this classid? Is there something in "direct_packets_stats"?
> Maybe: "ethtool -k $DEV", BTW?
>
> Jarek P.


