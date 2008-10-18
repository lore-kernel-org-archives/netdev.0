From: Oliver Hartkopp <oliver@hartkopp.net>
Subject: Re: hardware time stamps + existing time stamp usage
Date: Sat, 18 Oct 2008 12:10:24 +0200
Message-ID: <48F9B610.2090504@hartkopp.net>
References: <1224253423.17450.211.camel@ecld0pohly> <48F96DD6.5060904@cosmosbay.com> <48F99286.9050706@hartkopp.net> <48F9A43A.7070801@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick Ohly <patrick.ohly@intel.com>, netdev@vger.kernel.org,
	Octavian Purdila <opurdila@ixiacom.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Ingo Oeser <netdev@axxeo.de>, Andi Kleen <ak@linux.intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.160]:42045 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750872AbYJRKKf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Oct 2008 06:10:35 -0400
In-Reply-To: <48F9A43A.7070801@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> Oliver Hartkopp a =E9crit :
>> Eric Dumazet wrote:
>>
>>> 2) You want hardware RX stamping on a particular device, yet being=20
>>> able to
>>>   deliver system time to legacy apps, unaware of hardware tstamps.
>>>
>>>   Set a global flag on device, telling linux stack this device feed=
s=20
>>> hardware stamp.
>>>   In driver RX completion, set skb tstamp with hardware stamps.
>>>

But at this point you would also need to save the system timestamp into=
=20
the skb for sockets that do not want the hardware timestamp. The device=
=20
driver has no chance to know whether the socket this skb is sent to=20
wants hw tstamps or not.

>>>   Mark a WANT_HARDWARE_RX_STAMP flag at socket level, for PTP=20
>>> applications.
>>>
>>>   In recv(), if current socket is not marked WANT_HARDWARE_RX_STAMP=
=20
>>> and device has
>>>   the global flag set, copy system time in tstamp, overrinding=20
>>> hardware tstamp.
>>>
>>>
>>
>> Looks good to me. Just one question regarding
>> 'copy system time in tstamp, overrinding hardware tstamp':
>>
>> When recv() delivers to several sockets there would be probably=20
>> *different* system time values copied and delivered for the *same*=20
>> skb, right?
>
> As we introduced a new skb flag for the TX part, we could reuse it in=
=20
> order
> to copy system time to tstamp only once for the RX part.

But this does not help on received packets, right?

>>
>> If so i would tend to fill both (system time and hw timestamp) on=20
>> driver level into the skb and then decide on socket level what to=20
>> push into user space as you suggested above.
>
> Well, this would enlarge skb structure by 8 bytes, since you cannot u=
se
> same tstamp location to fille both 8 bytes values.
> This is probably the easy way, but very expensive...

IMHO this is the only way to fulfill the given requirements.
Maybe we should introduce a new kernel config option for hw tstamps the=
n ...

Regards,
Oliver
