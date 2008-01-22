From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: WARNING, tcp_fastretrans_alert, rc6-git11
Date: Wed, 23 Jan 2008 00:33:24 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0801230003230.32487@kivilampi-30.cs.helsinki.fi>
References: <20080122211652.M43631@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:54993 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751087AbYAVWd1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2008 17:33:27 -0500
In-Reply-To: <20080122211652.M43631@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 22 Jan 2008, Denys Fedoryshchenko wrote:

> Just got on one of proxies, under high load.
> It is a bit old rc, so probably my report not interesting, but since it is 
> production machines, i cannot change too often.
> Kernel is 2.6.24-rc6-git11

It's not at all useless, there hasn't been any TCP changes lately so this 
is still very much valid.

> Some sysctl adjustments done. Please tell me if need more information.

TCP related sysctl setting would be nice to know (I don't care much about 
mem sizes but others tweaks affecting TCP features are nice to know).

...snip...
> [9561199.893090] WARNING: at net/ipv4/tcp_input.c:2391 tcp_fastretrans_alert()

This check includes fixing if there's miscount (couple of releases ago 
we didn't even care to print that but had inaccurate fackets_out as a 
feature, there still may be some left-overs though I've tried to track 
them down).

To find out cause more accurately (this WARN_ON is just for alerting), I'd 
need to add rather exhaustive searching per ACK which unlikely is 
acceptable for you. Luckily, Dave Young reported one problem lately 
(though he was running brand new mm) which could be caused by the same 
problem as this, so it's not that bad even though you couldn't run skb 
state verifying.

Thanks anyway for the report.

-- 
 i.
