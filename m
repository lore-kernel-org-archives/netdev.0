From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [RFC v2 2/2] e100: Support RXFCS feature flag.
Date: Tue, 12 Jul 2011 17:49:49 +0200
Message-ID: <CAHXqBFL-QgKvrvcrjtjSgDdeH9i7Ai86U2ujQ4xpo-vXLEkO5A@mail.gmail.com>
References: <1308942371-12748-1-git-send-email-greearb@candelatech.com>
 <1308942371-12748-3-git-send-email-greearb@candelatech.com>
 <BANLkTiknCV1HknVpEdK97yU8eJwaJ5Y5Ag@mail.gmail.com> <4E0B3510.2080202@candelatech.com>
 <BANLkTikaJNa2+jbW6HWwc+tEE-ciNxvkLg@mail.gmail.com> <4E0B383E.8020807@candelatech.com>
 <BANLkTi=-ibpBiWBZ=AANybmWMWfMVGfe4Q@mail.gmail.com> <4E0B42CE.30400@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:57117 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753680Ab1GLPuK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jul 2011 11:50:10 -0400
Received: by qyk29 with SMTP id 29so2046831qyk.19
        for <netdev@vger.kernel.org>; Tue, 12 Jul 2011 08:50:09 -0700 (PDT)
In-Reply-To: <4E0B42CE.30400@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

W dniu 29 czerwca 2011 17:20 u=BFytkownik Ben Greear
<greearb@candelatech.com> napisa=B3:
> On 06/29/2011 08:06 AM, Micha=B3 Miros=B3aw wrote:
>> W dniu 29 czerwca 2011 16:35 u=BFytkownik Ben Greear
>> <greearb@candelatech.com> =A0napisa=B3:
>>> On 06/29/2011 07:33 AM, Micha=B3 Miros=B3aw wrote:
>>>>
>>>> W dniu 29 czerwca 2011 16:22 u=BFytkownik Ben Greear
>>>> <greearb@candelatech.com> =A0 =A0napisa=B3:
[...]
>>>>> I thought 'features' was what the NIC could support, and
>>>>> wanted_features
>>>>> was what the NIC was currently configured to support? =A0I don't =
want
>>>>> to rx the CRC all the time, just when users enable it...
>>>> hw_features is what device could support, and features is what dev=
ice
>>>> has currently turned on.
>>> Ok, thanks for that correction.
>>> What does wanted_features mean, then?
>> What user wants to be active. It should be more clear to you if you
>> read the implemetation: netdev_update_features() and friends.
>
> I read it. =A0Seems the code won't let you turn on something not supp=
orted,
> so if user wants RXFCS, then wanted_features will have it enabled. =A0=
So,
> I'm not sure why my e100 patch would be wrong in that case.

wanted_features only reflects what is requested by user, this
combination might be invalid. When conditions change this value
combined with other bits in features are passed through
ndo_fix_features callback and netdev_fix_features() to bring it to
valid state, and then (if resulting set is different than current
features) ndo_set_features() is called to reconfigure device for that
new state change to it.

Best Regards,
Micha=B3 Miros=B3aw
