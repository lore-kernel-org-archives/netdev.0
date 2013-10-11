From: Fan Du <fan.du@windriver.com>
Subject: Re: [PATCH RFC 0/2] xfrm: Remove ancient sleeping code
Date: Fri, 11 Oct 2013 15:18:40 +0800
Message-ID: <5257A650.4090408@windriver.com>
References: <20131010063301.GO7660@secunet.com> <525650F6.305@windriver.com> <20131010085703.GR7660@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:36217 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752945Ab3JKHT2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Oct 2013 03:19:28 -0400
In-Reply-To: <20131010085703.GR7660@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

hehe, I didn't object this cleanup except learning from it :)

On 2013=E5=B9=B410=E6=9C=8810=E6=97=A5 16:57, Steffen Klassert wrote:
> On Thu, Oct 10, 2013 at 03:02:14PM +0800, Fan Du wrote:
>>
>>
>> On 2013=E5=B9=B410=E6=9C=8810=E6=97=A5 14:33, Steffen Klassert wrote=
:
>>> Does anyone still rely on the ancient sleeping when the SA is in
>>> acquire state? It is disabled by default since more that five years=
,
>>> but can cause indefinite task hangs if enabled and the needed state
>>> does not get resolved.
>>
>> I saw that "can_sleep" is set true in ip_route_connect which upper l=
ayer
>> protocol relies on it, which ensure not dropping *any* skb.
>
> 'Any' means one per task in this context. Also, we can't ensure that
> this packet reaches it's destination. So where is the difference
> between dropping the packet locally or on the network?
>
>> And acquire timer will make sure the task will not hangs indefinitel=
y.
>>
>
> Did you try that? It makes sure that the task wakes up from time to t=
ime,
> but it goes immediately back to sleep if the needed state is not reso=
lved.
> The only terminating contition is when the task gets a signal to exit=
=2E
>
>> In xfrm policy queue, XFRM_MAX_QUEUE_LEN is 100, which means 101th s=
kb
>> will be dropped, how about make it configurable?
>
> IMO we would have yet another useless knob then. Currently we send al=
l
> packets by default to a blackhole as long as the state is not resolve=
d
> and most people are fine with it. The queueing is mostly to speed up
> tcp handshakes,

I cannot follow on this part. Would you please mind to explain how maki=
ng a
policy queue will speed up TCP handshakes than orignal CAN_SLEEP mechan=
ism?


Thanks

--=20
=E6=B5=AE=E6=B2=89=E9=9A=8F=E6=B5=AA=E5=8F=AA=E8=AE=B0=E4=BB=8A=E6=9C=9D=
=E7=AC=91

--fan
