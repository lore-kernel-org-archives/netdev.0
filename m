From: Benjamin LaHaise <bcrl@lhnet.ca>
Subject: Re: [net-next-2.6 PATCH] net: fast consecutive name allocation
Date: Sun, 15 Nov 2009 11:50:15 -0500
Message-ID: <20091115165015.GU19478@kvack.org>
References: <20091113233504.GQ19478@kvack.org> <20091113.185937.251557071.davem@davemloft.net> <20091115090604.331d75c2@opy.nosense.org> <200911150355.15204.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mark Smith <lk-netdev@lk-netdev.nosense.org>,
	David Miller <davem@davemloft.net>, shemminger@vyatta.com,
	opurdila@ixiacom.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org
To: Denys Fedoryschenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([205.233.56.17]:48130 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751844AbZKOQuK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 15 Nov 2009 11:50:10 -0500
Content-Disposition: inline
In-Reply-To: <200911150355.15204.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Denys,

On Sun, Nov 15, 2009 at 03:55:14AM +0200, Denys Fedoryschenko wrote:
> And interface creation speed is important for me, when electricity goes down 
> here, many customers disconnects (up to 500 on single NAS), and then join 
> again to NAS. Load average was jumping to sky on such situations, just option 
> to not create sysfs entries helped me a lot (was posted recently).
> Electricity outage is usual here, happens 2-3 times daily.

This is exactly the type of scenario I'm looking at.  The design of the 
Babylon PPP stack is meant to scale somewhat better that pppd.  It uses a 
single process (although I'm starting to add threads to improve scaling on 
SMP systems) for all PPP/L2TP sessions, and has rather lower connection 
setup overhead (no fork()/exec() being the biggest one).  With udev tuned, 
irqbalance disabled and a few other tweaks, it gets >500 connections per 
second in startup on a modern 2.6GHz processor for L2TP traffic.  There 
is PPPoE support, but it needs a bit more work done to scale automatically 
(there are a few hardcoded limits in the PPPoE implementation).

		-ben
