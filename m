From: Patrick McHardy <kaber@trash.net>
Subject: Re: iproute2 proposal
Date: Wed, 06 Aug 2008 10:28:35 +0200
Message-ID: <489960B3.4050708@trash.net>
References: <200808060125.38260.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:42162 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757125AbYHFI2j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Aug 2008 04:28:39 -0400
In-Reply-To: <200808060125.38260.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Denys Fedoryshchenko wrote:
> While using iproute2 in batch mode i notice that adding 11362 rules, on system 
> with 500+ interfaces takes up to 1minute on Xeon 3.0 Ghz.
> After "oprofiling" i got result:
>
> CPU: P4 / Xeon with 2 hyper-threads, speed 2992.84 MHz (estimated)
> Counted GLOBAL_POWER_EVENTS events (time during which processor is not 
> stopped) with a unit mask of 0x01 (mandatory) count 100000
> samples  %        image name               symbol name
> 86166    57.3473  tc                       ll_remember_index
> 48103    32.0147  tc                       parse_rtattr
> 8497      5.6551  tc                       rtnl_dump_filter
> 1751      1.1654  [vdso] (tgid:22801 range:0xb7f66000-0xb7f67000) (no symbols)
> 1085      0.7221  tc                       tc_calc_xmittime
> 672       0.4472  tc                       .plt
>
> I did small patch, and voila! batch finished in 2 seconds successfully!
>
> Proof of concept patch is attached. Not sure if it is not breaking any other 
> things. Waiting for any comments.

It breaks batches that add links and then configure them. You need
to invalidate the link map on "ip link add/del" and "ip tunnel add/del".
