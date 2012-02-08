From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH 1/5] send-crc: Add framework to allow sending packets
 with customized CRC.
Date: Tue, 07 Feb 2012 16:06:00 -0800
Message-ID: <4F31BC68.9000502@candelatech.com>
References: <1328644182-7872-1-git-send-email-greearb@candelatech.com> <CAHXqBFKe+nAGk8gjjOxRSbgtPSPHXcz3_fNjaBaxh48vPvDysQ@mail.gmail.com> <4F318CF5.1060200@candelatech.com> <CAHXqBFKbv13jL_RqbOTZp6P-TOO7iQ1211SXmMso_3LK27LkPw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:44752 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755998Ab2BHAGD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2012 19:06:03 -0500
In-Reply-To: <CAHXqBFKbv13jL_RqbOTZp6P-TOO7iQ1211SXmMso_3LK27LkPw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/07/2012 03:59 PM, Micha=B3 Miros=B3aw wrote:
> W dniu 7 lutego 2012 21:43 u=BFytkownik Ben Greear
> <greearb@candelatech.com>  napisa=B3:
>> On 02/07/2012 12:33 PM, Micha=B3 Miros=B3aw wrote:
>>>
>>> 2012/2/7<greearb@candelatech.com>:
>>>>
>>>> From: Ben Greear<greearb@candelatech.com>
>>>>
>>>> This is useful for testing RX handling of frames with bad
>>>> CRCs.
>>>>
>>>> Requires driver support to actually put the packet on the
>>>> wire properly.
>>>
>>> [...]
>>>
>>> I like this idea. I think that this is not a feature to have in
>>> dev->features to toggle, though. Driver either supports this or not=
,
>>> so it's better to put it in dev->priv_flags instead. Disabling of F=
CS
>>> inserting is a per-packet option in the drivers, isn't it?
>>>
>>> For one problem with toggling: if you create a socket using it and
>>> later turn off the feature, the socket will still send skbs with FC=
S
>>> appended.
>> For the priv-flags, is there a way to query that from user-space to
>> see if the NIC supports it?
>>
>> The pkt-socket xmit logic will throw away pkts if the NIC doesn't
>> have the feature enabled, but a few already queued might get
>> through with extra CRC appended.
>>
>> So, I'm fine with your suggestion, as long as there is some way to
>> query whether the NIC supports this feature or not...
>
> There's a way, as you implemented -EINVAL when trying to send via
> unsupporting device. :-)  Would be even better if setting SO_NO_FCS
> would fail at setsockopt() time.

Using -EINVAL for this purpose is lame even by my low standards :)

And, you don't necessarily know what device you are bound to
at setsockopt time, so I don't think I can add restrictions
there.

> priv_flags are not exposed to userspace. It should be easy to export
> them using ETHTOOL_GFEATURES as non-changeable features, if that's
> useful.

I'll poke around and see what I can figure out.

Thanks,
Ben

--=20
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
