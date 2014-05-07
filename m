From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] tcp: add support for scheduling TCP options on TCP
 sockets
Date: Wed, 07 May 2014 12:48:59 -0400 (EDT)
Message-ID: <20140507.124859.310105705013032741.davem@davemloft.net>
References: <1399399524-28550-1-git-send-email-octavian.purdila@intel.com>
	<20140507.013820.1357850416047414291.davem@davemloft.net>
	<CAE1zotJXpM+crFYE8-95G6s77BGvWF0LUUNgvCjQPcr-nbmzAA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, christoph.paasch@uclouvain.be
To: octavian.purdila@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49769 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932134AbaEGQtF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2014 12:49:05 -0400
In-Reply-To: <CAE1zotJXpM+crFYE8-95G6s77BGvWF0LUUNgvCjQPcr-nbmzAA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Octavian Purdila <octavian.purdila@intel.com>
Date: Wed, 7 May 2014 10:30:23 +0300

> On Wed, May 7, 2014 at 8:38 AM, David Miller <davem@davemloft.net> wrote:
>>
>> From: Octavian Purdila <octavian.purdila@intel.com>
>> Date: Tue,  6 May 2014 21:05:24 +0300
>>
>> > Pardon the rough patch, but I hope it is enough to get some feedback
>> > on the overall approach.
>>
>> Sorry I don't like this.
>>
>> Walking a linked list unnecessary is going to add overhead to every
>> single packet transmission.  I think more people want our TCP stack to
>> be fast (everyone) than those who want option processing to be
>> abstracted enough to be modular (you).
>>
>> Just make the intrusive changes, they are necessary as they force you
>> to think fully about how one option might interact with another.
>>
> 
> Unfortunately skb_tcp_cb does not have enough space to hold
> information for new large options. To work around that, the MPTCP
> implementation is pushing the option data in the skb and then
> occasionally uses the following when the pskb_copy is used:

Why not deal with the problem directly by trying to find a way to
compress the existing use of skb_tcp_cb() so that there is actually
the amount of space you need?

That is the approach I definitely prefer you take.
