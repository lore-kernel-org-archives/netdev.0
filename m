From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC] multiqueue changes
Date: Thu, 29 Oct 2009 23:12:39 +0100
Message-ID: <4AEA1357.3090307@trash.net>
References: <4ACD9255.4020008@gmail.com> <20091008090344.GA7409@ff.dom.local> <20091008120039.GA8691@ff.dom.local> <4AE87EEE.4020703@trash.net> <20091028212337.GA3218@ami.dom.local> <4AE9C4C3.9040503@trash.net> <20091029211543.GA3036@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:60541 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756159AbZJ2WMm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Oct 2009 18:12:42 -0400
In-Reply-To: <20091029211543.GA3036@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> On Thu, Oct 29, 2009 at 05:37:23PM +0100, Patrick McHardy wrote:
> ...
>> Well, we do need both values for supporting changes to the actually
>> used numbers of TX queues. If I understood Dave's explanation correctly,
>> this is also what's intended. It also doesn't seem unreasonable
>> what bnx2 is doing.
> 
> Exactly. With a growing number of cores, both available and powered
> off, these values will be soon treated more carefully than now.
> 
>> But getting back to the problem Eric reported - so you're suggesting
>> that bnx2.c should also adjust num_tx_queues in case the hardware
>> doesn't support multiqueue? That seems reasonable as well.
> 
> Currently, declaring num_tx_queues with alloc_netdev_mq() looks like
> too soon for some drivers. It seems they should be able to do it
> separately later during the .probe.

The value passed into alloc_netdev_mq() is just used for allocation
purposes, from what I can tell there's no downside in reducing it
before the dev_activate() call.

> There is a question if .ndo_open should be considered too.

I currently can't see any purpose in decreasing num_tx_queues after
registration instead of real_num_tx_queues. But it depends on how
exactly this will be implemented and how it interacts with qdiscs
(hence me previous mail, where I tried to point out possible
inconsistencies from using real_num_tx_queues).
