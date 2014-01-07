From: Fan Du <fan.du@windriver.com>
Subject: Re: [PATCHv4 net-next] xfrm: Namespacify xfrm_policy_sk_bundles
Date: Tue, 7 Jan 2014 10:43:38 +0800
Message-ID: <52CB69DA.7000101@windriver.com>
References: <1387342211.19078.295.camel@edumazet-glaptop2.roam.corp.google.com> <52B24D7D.6060902@windriver.com> <1387419308.19078.343.camel@edumazet-glaptop2.roam.corp.google.com> <52B26553.9070103@windriver.com> <1387424650.19078.355.camel@edumazet-glaptop2.roam.corp.google.com> <52B3BAD1.30205@windriver.com> <20131224103521.GB29716@secunet.com> <52BA7DE4.9070404@windriver.com> <20131225101104.224f9b87@vostro> <52BA9AEA.7050301@windriver.com> <20140106103512.GR31491@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Timo Teras <timo.teras@iki.fi>,
	Eric Dumazet <eric.dumazet@gmail.com>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:46471 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756500AbaAGCmp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jan 2014 21:42:45 -0500
In-Reply-To: <20140106103512.GR31491@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2014=E5=B9=B401=E6=9C=8806=E6=97=A5 18:35, Steffen Klassert wrote:
> On Wed, Dec 25, 2013 at 04:44:26PM +0800, Fan Du wrote:
>>
>>
>> On 2013=E5=B9=B412=E6=9C=8825=E6=97=A5 16:11, Timo Teras wrote:
>>> On Wed, 25 Dec 2013 14:40:36 +0800
>>> Fan Du<fan.du@windriver.com>   wrote:
>>>
>>>>>   ccing Timo
>>>>>
>>>>>   On 2013=E5=B9=B412=E6=9C=8824=E6=97=A5 18:35, Steffen Klassert =
wrote:
>>>>>>   >   On Fri, Dec 20, 2013 at 11:34:41AM +0800, Fan Du wrote:
>>>>>>>   >>
>>>>>>>   >>   Subject: [PATCHv4 net-next] xfrm: Namespacify
>>>>>>>   >>   xfrm_policy_sk_bundles
>>>>>>>   >>
>>>>>>>   >>   xfrm_policy_sk_bundles, protected by
>>>>>>>   >>   net->xfrm.xfrm_policy_sk_bundle_lock should be put into =
netns xfrm
>>>>>>>   >>   structure, otherwise xfrm_policy_sk_bundles can be corru=
pted from
>>>>>>>   >>   different net namespace.
>>>>>>   >
>>>>>>   >   I'm ok with this patch, but I wonder where we use these ca=
ched
>>>>>>   >   socket bundles. After a quick look I see where we add and =
where we
>>>>>>   >   delete them, but I can't see how we use these cached bundl=
es.
>>>>>
>>>>>   Interesting
>>>>>
>>>>>   The per socket bundles is introduced by Timo in commit 80c802f3
>>>>>   ("xfrm: cache bundles instead of policies for outgoing flows")
>>> Those existed even before. I just did systematic transformation of =
the
>>> caching code to work on bundle level instead of policy level.
>>
>> Apologizes and thanks for your quick reply :)
>>
>>>>>   But one fundamental question is why not use existing flow cache
>>>>>   for per socket bundles as well? then no need to create such per
>>>>>   sock xdst for every packet, and also share the same flow cache
>>>>>   flush mechanism.
>>> It was needed when the flow cache cached policies. They explicitly
>>> needed to check the socket for per-socket policy. So it made no sen=
se
>>> to have anything socket related in the cache.
>>
>> I understand your concern.
>>
>> per sk bundles could be distinguished by putting per sk policy point=
er into
>> struct flow_cache_entry, and then compare sk policy between cached p=
olicy
>> against with sk policy.

Yes, I tested sk policy with udp, when transmit, dst will be cached int=
o sk
by sk_dst_set. Let's leave current implementation as it is.

Please kindly review if there is any concern about v4.

> Most protocols cache the used routes at the sockets, so I'm not sure =
if
> we really need to cache them in xfrm too.
>
> Given the fact that we don't use these cached socket policy bundles,
> it would be already an improvement if we would simply remove this cac=
hing.
> All we are doing here is wasting memory.
>>
>> And I also notice flow cache is global across different namespaces, =
but flow
>> cache flush is doing a per-cpu(also global) operation, that's not fa=
ir for
>> slim netns as compared with fat netns which floods flow cache. Maybe=
 it's
>> time to make flow cache also name space aware.
>
> Yes, making the flow cache namespace aware would be a good thing.
>

I will give it a try :)

--=20
=E6=B5=AE=E6=B2=89=E9=9A=8F=E6=B5=AA=E5=8F=AA=E8=AE=B0=E4=BB=8A=E6=9C=9D=
=E7=AC=91

--fan
