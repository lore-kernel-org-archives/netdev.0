From: David Ahern <dsahern@gmail.com>
Subject: Re: [RFC PATCH 00/29] net: VRF support
Date: Thu, 05 Feb 2015 18:32:22 -0700
Message-ID: <54D419A6.1030902@gmail.com>
References: <1423100070-31848-1-git-send-email-dsahern@gmail.com> <54D373B4.3050603@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ebiederm@xmission.com
To: nicolas.dichtel@6wind.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f180.google.com ([209.85.213.180]:50217 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752782AbbBFBcd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2015 20:32:33 -0500
Received: by mail-ig0-f180.google.com with SMTP id b16so4025210igk.1
        for <netdev@vger.kernel.org>; Thu, 05 Feb 2015 17:32:32 -0800 (PST)
In-Reply-To: <54D373B4.3050603@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/5/15 6:44 AM, Nicolas Dichtel wrote:
> Le 05/02/2015 02:34, David Ahern a =C3=A9crit :
> [snip]
>> This is accomplished by enhancing the current namespace checks to a
>> broader network context that is both a namepsace and a VRF id. The V=
RF
>> id is a tag applied to relevant structures, an integer between 1 and=
 4095
>> which allows for 4095 VRFs (could have 0 be the default VRF and then=
 the
>> range is 0-4095 =3D 4096s VRFs). (The limitation is arguably artific=
ial. It
>> is based on the genid scheme for versioning networking data which is=
 a
>> 32-bit integer. The VRF id is the lower 12 bits of the genid's.)
> Would it be possible to avoid this artificial limit?
> There could be scenarii with more than 4096 vrf.

As I recall the genid was the only reason to put a limit on it. I know=20
of one product with a higher limit (16k I believe), but I figured this=20
was a reasonable start point for the discussion.

>
> Do you plan to have a way to dump or monitor VRF via netlink?

What do you mean? There is no creation / deletion event. Are you=20
referring to monitoring device changes -- device moved from one network=
=20
context (namespace, vrf) to another?

The VRF id can be added as an attribute to all relevant netlink=20
notifications.
