From: =?UTF-8?B?UMOhZHJhaWcgQnJhZHk=?= <P@draigBrady.com>
Subject: Re: route/max_size sysctl in ipv4
Date: Tue, 06 Jan 2015 12:41:51 +0000
Message-ID: <54ABD80F.7070602@draigBrady.com>
References: <CAOxq_8NdxBScZ182bXs5KmTZLKRMeF3AVt+DJNFUff42gaZG4w@mail.gmail.com> <20150105.193614.1827024424476781168.davem@davemloft.net> <CAOxq_8OtQ0WD-PKBd4kX0JwZiaStqJ-cQiQRhWnTAK9Q0JquxA@mail.gmail.com> <20150105.195128.794605376092864881.davem@davemloft.net> <CAOxq_8OysjN8OrvhM13t3YUuyh5O=KM_mptR=NHieq146mqZ8g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ani Sinha <ani@arista.com>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.vodafone.ie ([213.233.128.44]:21335 "EHLO
	mail2.vodafone.ie" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754955AbbAFMmB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2015 07:42:01 -0500
In-Reply-To: <CAOxq_8OysjN8OrvhM13t3YUuyh5O=KM_mptR=NHieq146mqZ8g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/01/15 00:56, Ani Sinha wrote:
> On Mon, Jan 5, 2015 at 4:51 PM, David Miller <davem@davemloft.net> wr=
ote:
>> From: Ani Sinha <ani@arista.com>
>> Date: Mon, 5 Jan 2015 16:43:30 -0800
>>
>>> On Mon, Jan 5, 2015 at 4:36 PM, David Miller <davem@davemloft.net> =
wrote:
>>>> From: Ani Sinha <ani@arista.com>
>>>> Date: Mon, 5 Jan 2015 15:48:11 -0800
>>>>
>>>>> I am looking at the code and it looks like since the route cache =
for
>>>>> ipv4 was removed from the kernel, this sysctl parameter no longer
>>>>> serves the same purpose. It does not look like it is even used in=
 the
>>>>> ipv4/route.c module. Is there an equivalent sysctl parameter limi=
ting
>>>>> the number of route entries in the kernel? Or is there now no
>>>>> mechanism to limit the number of route entries?
>>>>
>>>> There is nothing to limit, since the cache was removed.
>>>
>>> Shouldn't the documentation be updated to reflect that? Also what's
>>> the point of having a dummy variable that does nothing? Should we n=
ot
>>> simply remove it?
>>
>> There is nothing to update, the behavior is completely transparent.
>> Absolutely no cache entries exist, therefore the limit cannot be
>> reached.
>=20
> I disagree. You are advertising a feature in an official documentatio=
n
> that simply does not exist for ipv4. This is very confusing. If I did
> not dig into the code, I wouldn't know that this particular knob is a
> noop since the time the route cache was removed.

You can't change APIs with impunity.

>> The sysctl is kept so that scripts reading it don't suddenly stop
>> working.  We can't just remove sysctl values.

Perhaps /proc/sys/net/ipv4/route/max_size should always return 0 when r=
ead,
and discard written values?

thanks,
P=C3=A1draig
