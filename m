From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [net-next PATCH v2 1/1] net sched actions: skbedit add support
 for mod-ing skb pkt_type
Date: Mon, 13 Jun 2016 07:52:30 -0400
Message-ID: <575E9E7E.6000507@mojatatu.com>
References: <1465766693-2336-1-git-send-email-jhs@emojatatu.com>
 <575E681B.8080500@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com
To: Daniel Borkmann <daniel@iogearbox.net>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:34590 "EHLO
	mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422836AbcFMLwd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 07:52:33 -0400
Received: by mail-it0-f68.google.com with SMTP id d71so6881737ith.1
        for <netdev@vger.kernel.org>; Mon, 13 Jun 2016 04:52:32 -0700 (PDT)
In-Reply-To: <575E681B.8080500@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-06-13 04:00 AM, Daniel Borkmann wrote:
> Hi Jamal,
>
> On 06/12/2016 11:24 PM, Jamal Hadi Salim wrote:
>> From: Jamal Hadi Salim <hadi@mojatatu.com>
>>
>> Extremely useful for setting packet type to host so i dont
>> have to modify the dst mac address using pedit (which requires
>> that i know the mac address)
>>
>> Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
>
> I'm wondering if this is a good idea, I was thinking about something
> like this as well some time ago.

Good ;-> What was your uses case?
In my case it is mostly to allow packets coming into the system
with the wrong MAC address (but correct IP address).
I dont want to keep checking what the MAC address is and adding
a rule to change it before it goes up the stack.

> So far pkt_type is just exposed as
> read-only to user space right now and I'm a bit worried that when we
> allow to set it arbitrarily, then this could lead to hard to debug
> issues since skb->pkt_type is used in a lot of places with possibly
> different assumptions and applications now need to mistrust the kernel
> whether skb->pkt_type was actually what the kernel itself set in the
> first place or skbedit with possibly some nonsense value (like rewriting
> PACKET_OUTGOING into PACKET_LOOPBACK, etc).

Separation of church from state.
In Unix we allow people to shoot their big toe if they want to.
If someone wants to change the destination MAC address to something
stupid they can. If someone wants to set the skbmark they can.
They'll find out it is a bad idea pretty quickly if it was not
what they intended. This is no different.

>Did you audit that this is safe?

Do you see a security issue? then that would need an audit.

cheers,
jamal
