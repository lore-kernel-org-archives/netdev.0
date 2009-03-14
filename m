From: Pantelis Koukousoulas <pktoss@gmail.com>
Subject: Re: [PATCH] Make virtio_net support carrier detection
Date: Sat, 14 Mar 2009 13:33:02 +0200
Message-ID: <1295ed070903140433h14a7070es27885b254af0a90e@mail.gmail.com>
References: <20090312.055235.56926675.davem@davemloft.net>
	 <200903131017.11572.rusty@rustcorp.com.au>
	 <20090313.120100.266753164.davem@davemloft.net>
	 <200903141049.43202.rusty@rustcorp.com.au>
	 <1295ed070903140340g5da5853cq51decf40e2fc03c8@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, dcbw@redhat.com,
	netdev@vger.kernel.org, markmc@redhat.com
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f177.google.com ([209.85.219.177]:63964 "EHLO
	mail-ew0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753997AbZCNLdF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Mar 2009 07:33:05 -0400
Received: by ewy25 with SMTP id 25so2872839ewy.37
        for <netdev@vger.kernel.org>; Sat, 14 Mar 2009 04:33:02 -0700 (PDT)
In-Reply-To: <1295ed070903140340g5da5853cq51decf40e2fc03c8@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Mar 14, 2009 at 12:40 PM, Pantelis Koukousoulas
<pktoss@gmail.com> wrote:
>> I don't think it was straightforward at all. =A0Current virtio_net "=
cards"
>> don't support carrier detection. =A0We reported that (correctly) to =
userspace,
>> like every other driver which doesn't support carrier detect.
>>
>> So why is virtio_net different? =A0Or should all devices which can't=
 detect
>> carrier set it to on, so older NetworkManagers work?
>>
>
[snip]
>
> So, I still propose my version for 2.6.29 / -stable and then mark's
> commit applies
> on top of that just fine (just don't delete the netif_carrier_on) =A0=
and
> adds the feature
> of the user being able to set the status to on / off explicitly if
> they have a new version
> of qemu / virtio while still doing the "right thing" for current vers=
ions.
>
> Therefore, I guess I should resend my patch to netdev with reworked c=
omments
> to reflect this discussion. Hope that is ok with you too.
>
> Pantelis

Or, we can merge the extra netif_carrier_on (what your patch did) to
mark's commit
and just add that full thing to 2.6.29 (as 2 patches probably because
of git, but
one next to the other please for bisection / readability reasons).

I just tested this solution with a self-made livecd, it applies
cleanly and works fine :)
(it might be ~42 lines instead of 2 but it is still trivial enough to
be confident that
nothing will break).

This way we get the expected result for every combination of current an=
d future
versions of qemu / kernel without ever having one "lie" to the other or=
 innocent
users becoming frustrated.

Again:
 (1) My version: smallest, only takes into account current "hardware",
might lead
   to a surprise for someone that uses a future qemu with 2.6.29, does
set_link off
   and expects to see "operation not supported" in ethtool instead of
"Link detected: yes".

 (2) Mark's commit: proper implementation (does both the hardware and
driver part),
       but will only work right for future qemu versions.

 (3) The 2 merged: work for all combinations of current and future
kernel / qemu.
   42 lines instead of 2 but just as unlikely to cause breakage.


I 'd be happy with either (3) in 2.6.29, or (1) in 2.6.29 and (2) in 2.=
6.30.

Just please don't select to "do nothing". That would be wrong :)

Pantelis
