From: denys@visp.net.lb
Subject: Re: NMI lockup, 2.6.26 release
Date: Sat, 26 Jul 2008 00:09:52 +0300
Message-ID: <200807260009.52838.denys@visp.net.lb>
References: <200807222142.23710.denys@visp.net.lb> <200807240256.36098.denys@visp.net.lb> <20080725073628.GA10399@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: denys@visp.net.lb, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2.globalproof.net ([194.146.153.25]:58112 "EHLO
	relay2.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750991AbYGYVKM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jul 2008 17:10:12 -0400
In-Reply-To: <20080725073628.GA10399@ff.dom.local>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I will try to explain all details, maybe anything matter

around 150-300 megs passing
Core 2 Duo E6750
3 ifb's
29 htb classes (summary)
26 qdiscs (sfq and bfifo)
NAT is running (465-700K connections)
maximum bfifo qdisc size is 600Kbyte
mostly all filters u32 (one is police mtu)
quantum is 1514, one is 1515
Load is low (below 30-35)% by mpstat

The only error i have in dmesg (a LOT of this messages, different ip port, )
[162014.265116] UDP: short packet: From 200.122.35.205:64599 8409/1480 to 
213.254.233.9:6073
[162014.373110] UDP: short packet: From 200.122.35.205:52015 10698/1480 to 
213.254.233.9:4855

[162088.232099] UDP: bad checksum. From 96.234.33.9:1077 to 
213.254.233.9:49520 ulen 111


I run time-warp-test from Ingo Molnar - nothing, no warps.

If required - i can send all rules to private e-mail.

I will apply patch after 30-60 minutes (off peak time). Thanks for help a lot!

On Friday 25 July 2008, Jarek Poplawski wrote:
> Hi Denys,
>
> In case this is still working after hrtimer -> timer change here is
> another patch for testing: to check if limiting hrtimers scheduling
> could matter here. Btw. could you write what is the approximate
> number of htb qdiscs and classes working on each device of this box
> (including ifbs)?
>
> Thanks,
> Jarek P.
>
> (This patch should be applided to 2.6.26 or .25 after reverting
> the previous debugging patch.)
>
> ---
>
