From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [RFC PATCH 00/29] net: VRF support
Date: Fri, 06 Feb 2015 09:53:01 +0100
Message-ID: <54D480ED.3050401@6wind.com>
References: <1423100070-31848-1-git-send-email-dsahern@gmail.com> <54D373B4.3050603@6wind.com> <54D419A6.1030902@gmail.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ebiederm@xmission.com
To: David Ahern <dsahern@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f171.google.com ([209.85.212.171]:40332 "EHLO
	mail-wi0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751164AbbBFIxF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Feb 2015 03:53:05 -0500
Received: by mail-wi0-f171.google.com with SMTP id l15so721519wiw.4
        for <netdev@vger.kernel.org>; Fri, 06 Feb 2015 00:53:02 -0800 (PST)
In-Reply-To: <54D419A6.1030902@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 06/02/2015 02:32, David Ahern a =C3=A9crit :
> On 2/5/15 6:44 AM, Nicolas Dichtel wrote:
>> Le 05/02/2015 02:34, David Ahern a =C3=A9crit :
>> [snip]
>>> This is accomplished by enhancing the current namespace checks to a
>>> broader network context that is both a namepsace and a VRF id. The =
VRF
>>> id is a tag applied to relevant structures, an integer between 1 an=
d 4095
>>> which allows for 4095 VRFs (could have 0 be the default VRF and the=
n the
>>> range is 0-4095 =3D 4096s VRFs). (The limitation is arguably artifi=
cial. It
>>> is based on the genid scheme for versioning networking data which i=
s a
>>> 32-bit integer. The VRF id is the lower 12 bits of the genid's.)
>> Would it be possible to avoid this artificial limit?
>> There could be scenarii with more than 4096 vrf.
>
> As I recall the genid was the only reason to put a limit on it. I kno=
w of one
> product with a higher limit (16k I believe), but I figured this was a=
 reasonable
> start point for the discussion.
Sure. My point was to be able to extend this limit in the future.

>>
>> Do you plan to have a way to dump or monitor VRF via netlink?
>
> What do you mean? There is no creation / deletion event. Are you refe=
rring to
> monitoring device changes -- device moved from one network context (n=
amespace,
> vrf) to another?
I mean getting the list of existing vrf.

>
> The VRF id can be added as an attribute to all relevant netlink notif=
ications.
I must think a bit more to this (is VRF an "object" or an attribute).
