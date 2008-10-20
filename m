From: Oliver Hartkopp <oliver@hartkopp.net>
Subject: Re: hardware time stamps + existing time stamp usage
Date: Mon, 20 Oct 2008 20:01:27 +0200
Message-ID: <48FCC777.4020506@hartkopp.net>
References: <1224253423.17450.211.camel@ecld0pohly>	 <48F96DD6.5060904@cosmosbay.com> <48F99286.9050706@hartkopp.net>	 <48F9A43A.7070801@cosmosbay.com>  <48F9B610.2090504@hartkopp.net> <1224488114.17450.224.camel@ecld0pohly>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Octavian Purdila <opurdila@ixiacom.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Ingo Oeser <netdev@axxeo.de>, Andi Kleen <ak@linux.intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>
To: Patrick Ohly <patrick.ohly@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.162]:12951 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752532AbYJTSDI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Oct 2008 14:03:08 -0400
In-Reply-To: <1224488114.17450.224.camel@ecld0pohly>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick Ohly wrote:
> On Sat, 2008-10-18 at 04:10 -0600, Oliver Hartkopp wrote:
>  =20
>> Eric Dumazet wrote:
>>    =20
>>> Oliver Hartkopp a =E9crit :
>>>      =20
>>>> If so i would tend to fill both (system time and hw timestamp) on
>>>> driver level into the skb and then decide on socket level what to
>>>> push into user space as you suggested above.
>>>>        =20
>>> Well, this would enlarge skb structure by 8 bytes, since you cannot=
 use
>>> same tstamp location to fille both 8 bytes values.
>>> This is probably the easy way, but very expensive...
>>>      =20
>> IMHO this is the only way to fulfill the given requirements.
>> Maybe we should introduce a new kernel config option for hw tstamps =
then ...
>>    =20
>
> The last time this topic was discussed the initial proposal also was =
to
> add another time stamp, pretty much for the same reasons. This approa=
ch
> was discarded because enlarging a common structure like skb for rathe=
r
> obscure ("Objection, your honor!" - "Rejected.") use cases is not
> acceptable.

I don't want to raise dust again but having HW timestamps are also=20
interesting for some CAN (Controller Area Network) users.
We had several discussions on the SocketCAN ML on HW timestamps that ar=
e=20
provided by some CAN controllers or active/intelligent CAN nodes (with=20
onboard-CPUs). For me it was not that relevant as stamping the skb in=20
the rx-path was always 'accurate enough' for me - but I'm not the CAN=20
timestamp expert. Fortunately the HW timestamp was not pushed into=20
skb->data (ugh!) but supporting HW timestamps for userspace apps is=20
still a wanted feature.

>  A config option doesn't help much either because to be
> useful for distribution users, it would have to be on by default.
>  =20

Hm - i tried to follow your points in the linked PDF=20
(http://www.linuxclustersinstitute.org/conferences/archive/2008/PDF/Ohl=
y_92221.pdf)=20
- and from my perspective having a kernel config option looks like an=20
appropriate solution here. Either some CAN controllers or HPC clusters=20
that would benefit from HW timestamps are IMHO no 'standard use-cases'=20
that use 'standard kernels' provided by a 'standard distributor', right=
?

I assume the system timestamps to be accurate enough for 'standard=20
users' so HW timestamps could be a possible candidate for a config=20
option - or did i miss anything vital here?

Especially it makes the implementation very clear and without any=20
expensive how-to-bitcompress-several-values-into-tstamp approaches.

Regards,
Oliver

