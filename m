From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH] make _minimum_ TCP retransmission timeout configurable
Date: Wed, 29 Aug 2007 15:29:03 -0700
Message-ID: <46D5F32F.2070502@hp.com>
References: <200708292052.NAA21975@tardy.cup.hp.com>	<5640c7e00708291432q6acde704od52247647a6b453@mail.gmail.com> <20070829.144656.104048365.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ian.mcdonald@jandi.co.nz, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel12.hp.com ([156.153.255.237]:34749 "EHLO palrel12.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753321AbXH2W3l (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Aug 2007 18:29:41 -0400
In-Reply-To: <20070829.144656.104048365.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
> Date: Thu, 30 Aug 2007 09:32:38 +1200
> 
> 
>>So I'm suspecting that the default should be changed to 1000 to match
>>the RFC which would solve this issue. I note that the RFC is a SHOULD
>>rather than a MUST. I had a quick look around and not sure why Linux
>>overrides the RFC on this one.
> 
> 
> Everyone uses this value, even BSD since ancient times.

Or at least something close to it - some use 500 milliseconds for 
"tcp_rto_min."

> None of the research folks want to commit to saying a lower value is
> OK, even though it's quite clear that on a local 10 gigabit link a
> minimum value of even 200 is absolutely and positively absurd.
> 
> So what do these cellphone network people want to do, increate the
> minimum RTO or increase it?  Exactly how does it help them?

They want to increase it.  The folks who triggered this want to make it 
3 seconds to avoid spurrious RTOs.  Their experience the "other 
platform" they widh to replace suggests that 3 seconds is a good value 
for their network.

> If the issue is wireless loss, algorithms like FRTO might help them,
> because FRTO tries to make a distinction between capacity losses
> (which should adjust cwnd) and radio losses (which are not capacity
> based and therefore should not affect cwnd).

I was looking at that.  FRTO seems only to affect the cwnd calculations, 
and not the RTO calculation, so it seems to "deal with" spurrious RTOs 
rather than preclude them.  There is a strong desire here to not have 
spurrious RTO's in the first place.  Each spurrious retransmission will 
increase a user's charges.

rick
