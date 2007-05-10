From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [RFC] New driver API to speed up small packets xmits
Date: Thu, 10 May 2007 15:21:30 -0400
Message-ID: <464370BA.3020907@hp.com>
References: <OF305F038C.A48D4C37-ON652572D7.00538ECA-652572D7.00546E39@in.ibm.com>	 <46435412.50800@hp.com> <464360D6.4080402@hp.com>	 <46436274.4060804@hp.com> <4643654F.5060207@hp.com> <5640c7e00705101159w68750a47xc06495e4395de583@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Rick Jones <rick.jones2@hp.com>,
	Krishna Kumar2 <krkumar2@in.ibm.com>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>, netdev@vger.kernel.org
To: Ian McDonald <ian.mcdonald@jandi.co.nz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel6.hp.com ([156.153.255.205]:52615 "EHLO atlrel6.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758047AbXEJTVc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 May 2007 15:21:32 -0400
In-Reply-To: <5640c7e00705101159w68750a47xc06495e4395de583@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ian McDonald wrote:
> On 5/11/07, Vlad Yasevich <vladislav.yasevich@hp.com> wrote:
>> >> May be for TCP?  What about other protocols?
>> >
>> > There are other protocols?-)  True, UDP, and I suppose certain modes of
>> > SCTP might be sending streams of small packets, as might TCP with
>> > TCP_NODELAY set.
>> >
>> > Do they often queue-up outside the driver?
>>
>> Not sure if DCCP might fall into this category as well...
>>
> Yes DCCP definitely can queue outside the driver.
> 
>> I think the idea of this patch is gather some number of these small
>> packets and
>> shove them at the driver in one go instead of each small packet at a
>> time.
>>
>> I might be helpful, but reserve judgment till I see more numbers.
>>
>> -vlad
> 
> As I see this proposed patch it is about reducing the number of "task
> switches" between the driver and the protocol. I use task switch in
> speech marks as it isn't really as is in the kernel. So in other words
> we are hoping that spending more time in each area would keep the
> cache hot and work to be done if locks held. This of course requires
> that the complexity added doesn't outweigh the gains - otherwise you
> could end up in a worse scenario where the driver doesn't send packets
> because the protocol is busy linking them.
> 
> As far as I can tell you're not combining packets?? This would
> definitely break UDP/DCCP which are datagram based.

If it's combining packets, it would break a lot of other things as well.

The proposed usage seems to be to link packets together into a chain
and give the whole chain to the driver, instead of handing down one packet
at a time.

The win might be biggest on a system were a lot of applications send a lot of
small packets.  Some number will aggregate in the prio queue and then get shoved
into a driver in one go.

But...  this is all conjecture until we see the code.

-vlad
