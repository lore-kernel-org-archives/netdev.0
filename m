From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH next v2 2/3] ipvlan: Process fragmented multicast
 frames correctly
Date: Mon, 04 May 2015 19:22:14 -0400 (EDT)
Message-ID: <20150504.192214.583143462067773210.davem@davemloft.net>
References: <1430331558-20286-1-git-send-email-maheshb@google.com>
	<20150501.211225.641281069847184355.davem@davemloft.net>
	<CAF2d9jhESPaPCtRsh7GWUY9Kue2h2D0Nw2Qv1H=Gj15M3twN0w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, dcbw@redhat.com
To: maheshb@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40304 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751161AbbEDXWQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2015 19:22:16 -0400
In-Reply-To: <CAF2d9jhESPaPCtRsh7GWUY9Kue2h2D0Nw2Qv1H=Gj15M3twN0w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <maheshb@google.com>
Date: Mon, 4 May 2015 15:58:59 -0700

> On Fri, May 1, 2015 at 6:12 PM, David Miller <davem@davemloft.net> wrote:
>> I am sorry but I am going to put my foot down and not allow another
>> instance of this to happen again.  We already have this being done by
>> netfilter, and I consider it unacceptable as well as inefficient.
>>
> Actually this will make the fragments processing more efficient. e.g.
> if there are 50 slave devices and we receive 10 fragments, the
> duplication will happen for 50*10 = 500 skbs but if the packet is
> defragmented, then it's only once per device making it more efficient.

You can linearize it 'zero' times, which is more efficient than
anything no matter how many interfaces.

And you can do this by maintaining a chain of the incoming SKBs and
then resegmenting them, which allows to maintain exactly the precise
geometry you started with in a guaranteed way.
