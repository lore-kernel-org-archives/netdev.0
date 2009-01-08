From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: HTB - very bad precision? HFSC works fine! 2.6.28
Date: Thu, 8 Jan 2009 09:27:20 +0000
Message-ID: <20090108092720.GC4496@ff.dom.local>
References: <200901080002.37223.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Denys Fedoryschenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f31.google.com ([209.85.219.31]:56796 "EHLO
	mail-ew0-f31.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753525AbZAHJ11 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2009 04:27:27 -0500
Received: by ewy12 with SMTP id 12so3094335ewy.13
        for <netdev@vger.kernel.org>; Thu, 08 Jan 2009 01:27:24 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <200901080002.37223.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07-01-2009 23:02, Denys Fedoryschenko wrote:
> I notice that our uplink ISP complaining, that we are exceeding our UP rate.
> 
> I have configured at HTB 60Mbps, but he is actually receiving bursts up to 
> 64Mbps.
> 
> I tried to lower down HTB values to 57Mbps, and even on Cisco switch interface 
> counter(it is averaging 30 seconds of data i guess, to calculate bandwidth) - 
> it shows 60.1 - 60.4.
> 
> Funny thing, root class in HTB shows 57.1 - 57.3 Mbps. So maybe byte counting 
> is wrong in HTB?

Does this "2.6.28" in the subject mean it was better before or not
tested? Could you do a few snapshots with: tc -s qdisc show dev $DEV

> 
> I have also "default filter" 
> tc filter add dev ${DEV} parent 1:0 protocol ip prio 800 u32 match ip src 
> 0.0.0.0/0 flowid 1:50

I can see "tc qdisc add ... default 1000" in your config; is there a
class with this classid? Is there something in "direct_packets_stats"?
Maybe: "ethtool -k $DEV", BTW?

Jarek P.
