From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH v2 2/3] net_sched: Add accessor function for packet length
 for qdiscs
Date: Sat, 26 Jul 2008 15:21:42 +0200
Message-ID: <488B24E6.4020003@trash.net>
References: <20080725105748.GB10399@ff.dom.local>	<20080725.035712.33516738.davem@davemloft.net>	<20080725113757.GC10399@ff.dom.local> <20080725.044928.261427957.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, jussi.kivilinna@mbnet.fi, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:63592 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751487AbYGZNVq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Jul 2008 09:21:46 -0400
In-Reply-To: <20080725.044928.261427957.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Jarek Poplawski <jarkao2@gmail.com>
> Date: Fri, 25 Jul 2008 11:37:57 +0000
> 
>> On Fri, Jul 25, 2008 at 03:57:12AM -0700, David Miller wrote:
>>> Even TCP depends upon that NET_XMIT_* return value having some real
>>> meaning, remember the HTB bug we tracked down last week? :-)
>> Do you mean this bug you've forgotten to fix yet?
> 
> I have not forgotten, it is in TODO list. :)
> 
> I want to also inquire with Patrick about whether he is going to
> perform the audit in this area which he said he wanted to do :-)

I'm a bit backlogged, so it will take some more time.

> Well, we have patch which fixes the problem for the tester, so we
> could just merge that and at least have HTB fixed.  But we know there
> are other instances of the same return value propagation problem and
> Patrick's audit is sure to turn up other similar turds...

The other problem that affects all qdiscs supporting actions is
TC_ACT_QUEUED/TC_ACT_STOLEN getting mapped to NET_XMIT_SUCCESS
even though the packet is not queued, corrupting upper qdiscs'
qlen counters.
