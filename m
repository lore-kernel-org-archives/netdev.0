From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC] multiqueue changes
Date: Thu, 29 Oct 2009 17:37:23 +0100
Message-ID: <4AE9C4C3.9040503@trash.net>
References: <4ACD9255.4020008@gmail.com> <20091008090344.GA7409@ff.dom.local> <20091008120039.GA8691@ff.dom.local> <4AE87EEE.4020703@trash.net> <20091028212337.GA3218@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:54367 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753208AbZJ2Qh1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Oct 2009 12:37:27 -0400
In-Reply-To: <20091028212337.GA3218@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> On Wed, Oct 28, 2009 at 06:27:10PM +0100, Patrick McHardy wrote:
>> We don't seem to be supporting changing real_num_tx_queues for
>> registered devices currently (at least I couldn't find it).
>> So I guess it depends on how this would be implemented.
>>
>> Simply changing the dev->real_num_tx_queues value while the
>> device is down would require qdisc operations to operate on
>> all possible queues since the amount of queues in use could
>> be changed after the qdisc is created/configured, but before
>> the device is set up. This approach has more complications
>> like switching between mq and non-mq root qdiscs, taking care
>> of non-default root qdisc (cloning them to the new queues), etc.
>>
>> A simpler alternative would be to destroy the existing root
>> qdisc on any change to real_num_tx_queues and have dev_activate()
>> set it up from scratch. In this case, we could (as you suggested)
>> use real_num_tx_queues, which should fix the problem Eric reported.
> 
> Actually, I changed my mind after Eric's and especially David's
> explanations. Probably there will be needed some changes in handling
> the real_num_tx_queues, but there is no reason to misuse them for
> masking a totally useless num_tx_queues value, like in this case. So,
> IMHO, its mainly about the driver(s) (and maybe a bit of API change)
> here.

Well, we do need both values for supporting changes to the actually
used numbers of TX queues. If I understood Dave's explanation correctly,
this is also what's intended. It also doesn't seem unreasonable
what bnx2 is doing.

But getting back to the problem Eric reported - so you're suggesting
that bnx2.c should also adjust num_tx_queues in case the hardware
doesn't support multiqueue? That seems reasonable as well.

