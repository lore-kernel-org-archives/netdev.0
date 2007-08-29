From: John Heffner <jheffner@psc.edu>
Subject: Re: [PATCH] make _minimum_ TCP retransmission timeout configurable
Date: Wed, 29 Aug 2007 18:48:40 -0400
Message-ID: <46D5F7C8.8090806@psc.edu>
References: <5640c7e00708291432q6acde704od52247647a6b453@mail.gmail.com>	<20070829.144656.104048365.davem@davemloft.net>	<46D5F32F.2070502@hp.com> <20070829.153503.18295527.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: rick.jones2@hp.com, ian.mcdonald@jandi.co.nz,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer1.psc.edu ([128.182.58.100]:56677 "EHLO mailer1.psc.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1749667AbXH2Wss (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Aug 2007 18:48:48 -0400
In-Reply-To: <20070829.153503.18295527.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Rick Jones <rick.jones2@hp.com>
> Date: Wed, 29 Aug 2007 15:29:03 -0700
> 
>> David Miller wrote:
>>> None of the research folks want to commit to saying a lower value is
>>> OK, even though it's quite clear that on a local 10 gigabit link a
>>> minimum value of even 200 is absolutely and positively absurd.
>>>
>>> So what do these cellphone network people want to do, increate the
>>> minimum RTO or increase it?  Exactly how does it help them?
>> They want to increase it.  The folks who triggered this want to make it 
>> 3 seconds to avoid spurrious RTOs.  Their experience the "other 
>> platform" they widh to replace suggests that 3 seconds is a good value 
>> for their network.
>>
>>> If the issue is wireless loss, algorithms like FRTO might help them,
>>> because FRTO tries to make a distinction between capacity losses
>>> (which should adjust cwnd) and radio losses (which are not capacity
>>> based and therefore should not affect cwnd).
>> I was looking at that.  FRTO seems only to affect the cwnd calculations, 
>> and not the RTO calculation, so it seems to "deal with" spurrious RTOs 
>> rather than preclude them.  There is a strong desire here to not have 
>> spurrious RTO's in the first place.  Each spurrious retransmission will 
>> increase a user's charges.
> 
> All of this seems to suggest that the RTO calculation is wrong.

I think there's definitely room for improving the RTO calculation. 
However, this may not be the end-all fix...


> It seems that packets in this network can be delayed several orders of
> magnitude longer than the usual round trip as measured by TCP.
> 
> What exactly causes such a huge delay?  What is the TCP measured RTO
> in these circumstances where spurious RTOs happen and a 3 second
> minimum RTO makes things better?

I haven't done a lot of work on wireless myself, but my understanding is 
that one of the biggest problems is the behavior link-layer 
retransmission schemes.  They can suddenly increase the delay of packets 
by a significant amount when you get a burst of radio interference. 
It's hard for TCP to gracefully handle this kind of jump without some 
minimum RTO, especially since wlan RTTs can often be quite small.

   -John
