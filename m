From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Q: bad routing table cache entries
Date: Wed, 13 Jan 2016 00:07:54 +0100
Message-ID: <5695874A.2010600@stressinduktion.org>
References: <5682665A.7090102@list.ru> <56951D1D.5080602@stressinduktion.org>
 <56952147.80201@stressinduktion.org> <569523C0.5040504@list.ru>
 <56952593.8040409@stressinduktion.org> <56952D01.6070204@list.ru>
 <56953059.1020506@list.ru> <569532A6.1070905@stressinduktion.org>
 <56953560.9050906@list.ru> <56953740.1090204@stressinduktion.org>
 <569538FD.2060200@list.ru> <56953C27.4030405@stressinduktion.org>
 <5695655A.60509@list.ru> <56957D95.1090307@stressinduktion.org>
 <569584CD.1040408@list.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Sowmini Varadhan <sowmini.varadhan@oracle.com>
To: Stas Sergeev <stsp@list.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:48706 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752934AbcALXIA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jan 2016 18:08:00 -0500
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id 53645203AC
	for <netdev@vger.kernel.org>; Tue, 12 Jan 2016 18:07:59 -0500 (EST)
In-Reply-To: <569584CD.1040408@list.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On 12.01.2016 23:57, Stas Sergeev wrote:
> 13.01.2016 01:26, Hannes Frederic Sowa =D0=BF=D0=B8=D1=88=D0=B5=D1=82=
:
>> I didn't check a full featured setup but just did some dirty testing
>> with namespaces and I had correct arp request for the now to be
>> assumed on-link router on the external veth.
> I haven't checked anything with arp.
> I set up tcpdump to only capture icmp.
> What would you like me to check, could you please
> give the detailed instructions?

Check simply for arp traffic on the interface. arp requests should leav=
e=20
your client and ask directly for the new router you got as next-hop. If=
=20
it does not answer, there is the problem.

>>> If it is not - how can I even see that it exist? How to
>>> list these redirect routes?
>>
>> Yeah, that might be a minor issue. The rt_cache procfs files are emp=
ty
>> since the deletion of the cache and we probably don't have an
>> interface for next hop exceptions, I consider this todo. :) ip route
>> get is your only hope right now.
>>
>> Anyway, seems like there are problems with redirect timeout somehow.=
 I
>> am investigating this.
>>
>>> I'd like to do some investigations, but this looks no
>>> more than a black magic without a proper support
>>> from tools, proper documentation, etc.
>>
>> Hmm, so far I think shared_media is behaving like it should,
> No, unless you correct the documentation:
> https://www.frozentux.net/ipsysctl-tutorial/chunkyhtml/theconfvariabl=
es.html
>
> It says not what you say.
> So this feature is essentially poorly (or wrongly) documented.

I am sorry, but I have no access to this website. I just grepped around=
=20
in the Documentation/ directory of the kernel:
<https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/tree/D=
ocumentation/networking/ip-sysctl.txt?id=3Drefs/tags/v4.4#n1014>

It is correctly documented there and also references the RFC. I think=20
this is fine. Please feel free to send a patch, it will be welcomed.

>> besides maybe it shouldn't be the default setting. Maybe someone who
>> can remember why it is default could chime in?
>>
>>> And I suspect that shared_media is disabled on a 0.1
>>> router, so I wonder if this can work at all, even if the node
>>> is cured to do the right thing with those redirects.
>>> In a nearby message David Miller says:
>>
>> Default is that shared_media is enabled,
> On what OS, and since what version?
>
>> so the chances are relatively high that it is enabled if it is not
>> turned off.
> I don't even know what is there in a 0.1 router - maybe windows95,
> who knows. You can't assume the latest linux kernel is everywhere.

Looking into the kernel cvs history the change was done in 2000(!).=20
Would be pretty strange to find such an old kernel there.

>>> ---
>>>
>>> 2) increasing the chance of successful communication with peers
>>>
>>> ---
>>> If this can't work right when one of the gateways has
>>> shared_media disabled, then this rule is clearly violated.
>>
>> It can work right and I think the RFC actually gives examples where =
it
>> is very useful. Also IPv6 adapts it as the default, so it might make
>> sense to have it as default.
>>
>> I still consider something broken in your network setup, maybe.
>>
>>>> ping requires the router to also find a correct way back, so packe=
t
>>>> can get stuck at a lot of places. Also uRPF is maybe active which =
kind
>>>> of defeats shared_media and please check netfilter.
>>> I am pretty sure the node has a default ubuntu without
>>> any special network tweaks, but I'll double-check.
>>
>> Please do that. Thanks!
> OK but please make it clear what should I check.
> iptables do not seem to be in the game, what else to check?

Please have a look for arp traffic as written before.

Thanks,
Hannes
