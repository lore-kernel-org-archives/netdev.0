From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [net-next PATCH v2 1/1] net sched actions: skbedit add support
 for mod-ing skb pkt_type
Date: Mon, 13 Jun 2016 14:21:11 +0200
Message-ID: <575EA537.9010807@iogearbox.net>
References: <1465766693-2336-1-git-send-email-jhs@emojatatu.com> <575E681B.8080500@iogearbox.net> <575E9E7E.6000507@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com, fw@strlen.de
To: Jamal Hadi Salim <jhs@mojatatu.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:36331 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965229AbcFMMVQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 08:21:16 -0400
In-Reply-To: <575E9E7E.6000507@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/13/2016 01:52 PM, Jamal Hadi Salim wrote:
> On 16-06-13 04:00 AM, Daniel Borkmann wrote:
>> Hi Jamal,
>>
>> On 06/12/2016 11:24 PM, Jamal Hadi Salim wrote:
>>> From: Jamal Hadi Salim <hadi@mojatatu.com>
>>>
>>> Extremely useful for setting packet type to host so i dont
>>> have to modify the dst mac address using pedit (which requires
>>> that i know the mac address)
>>>
>>> Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
>>
>> I'm wondering if this is a good idea, I was thinking about something
>> like this as well some time ago.
>
> Good ;-> What was your uses case?
> In my case it is mostly to allow packets coming into the system
> with the wrong MAC address (but correct IP address).
> I dont want to keep checking what the MAC address is and adding
> a rule to change it before it goes up the stack.

Yeah, had the same use-case here. ;)

>> So far pkt_type is just exposed as
>> read-only to user space right now and I'm a bit worried that when we
>> allow to set it arbitrarily, then this could lead to hard to debug
>> issues since skb->pkt_type is used in a lot of places with possibly
>> different assumptions and applications now need to mistrust the kernel
>> whether skb->pkt_type was actually what the kernel itself set in the
>> first place or skbedit with possibly some nonsense value (like rewriting
>> PACKET_OUTGOING into PACKET_LOOPBACK, etc).
>
> Separation of church from state.
> In Unix we allow people to shoot their big toe if they want to.
> If someone wants to change the destination MAC address to something
> stupid they can. If someone wants to set the skbmark they can.
> They'll find out it is a bad idea pretty quickly if it was not
> what they intended. This is no different.
>
>> Did you audit that this is safe?
>
> Do you see a security issue? then that would need an audit.

Looks like nft_meta_set_eval() can already do that, but restricted
via pkt_type_ok(), so we can't play bad games with PACKET_LOOPBACK
et al. Wasn't aware of that. Hm, so if you want to make use of this
from tc as well, probably it makes sense to add a generic helper as
in skb_pkt_type_mangle() and place it into skbuff.h?

Thanks,
Daniel
