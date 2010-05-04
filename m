From: David Miller <davem@davemloft.net>
Subject: Re: linux kernel's IPV6_MULTICAST_HOPS default is 64; should be 1?
Date: Tue, 04 May 2010 16:07:19 -0700 (PDT)
Message-ID: <20100504.160719.193718577.davem@davemloft.net>
References: <4BE031FA.6040006@hp.com>
	<20100504.144647.157477097.davem@davemloft.net>
	<AANLkTilPHlQ-CDSWnUn52al5DJfRxuZ8eiXwf3ep5LUD@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: brian.haley@hp.com, dlstevens@us.ibm.com, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org
To: enh@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35298
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934507Ab0EDXHO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 May 2010 19:07:14 -0400
In-Reply-To: <AANLkTilPHlQ-CDSWnUn52al5DJfRxuZ8eiXwf3ep5LUD@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: enh <enh@google.com>
Date: Tue, 4 May 2010 15:26:52 -0700

> On Tue, May 4, 2010 at 14:46, David Miller <davem@davemloft.net> wrote:
>> From: Brian Haley <brian.haley@hp.com>
>> Date: Tue, 04 May 2010 10:40:58 -0400
>>
>>> Specifying -1 for setsockopt(IPV6_MULTICAST_HOPS) should set the socket
>>> value back to the system default value of IPV6_DEFAULT_MCASTHOPS (1).
>>>
>>> Signed-off-by: Brian Haley <brian.haley@hp.com>
>>
>> In cast it wasn't clear from my other reply, I'm not applying this
>> patch because I intentionally left this behavior there based upon
>> some comments from Elliot in that this lets developers get the
>> old default by asking for "-1" explicitly with a setsockopt.
> 
> (for the record, i don't need that behavior myself, and have no
> opinion on whether or not it makes sense for you guys... i'll only
> ever call setsockopt with 0 <= value <= 255. all i need is for the
> default when i never call setsockopt to be 1. for now, i've added a
> work-around where i explicitly call setsockopt with 1 when i create
> the socket.)

It's more of an issue of having at least some kind of compatability
story when we change this.

With what's in the tree now we can at least say "if you explicitly
setsockopt() the value to '-1' you will get the same behavior now
as beforehand"

Whereas with what others are suggesting, we can't give people a way
in their applications to do that other than to suggest they use
disgusting concoctions like "set non-multicast hoplimit to '-1',
getsockopt() that, then set the multicast hop explicitly to that"

And even that won't work the same as now, in that changes to the
per-route metric will be ignored.
