From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: Off-by-one error in net/8021q/vlan.c
Date: Wed, 16 Feb 2011 19:41:34 +0100
Message-ID: <AANLkTimrQy6gU8d86m2jM4arMS0rOvEQmn2m-KTE4sx9@mail.gmail.com>
References: <4D5BADCF.5000804@ka9q.net>
	<AANLkTinBOk8ZNQvRpMqZQE_vOu63QVzDZ4ceRRUDvJD_@mail.gmail.com>
	<4D5BF411.4020204@ka9q.net>
	<AANLkTikNrwd31RBj1gc6kSaT=qodS=A=YntM=72PMbDf@mail.gmail.com>
	<4D5BFB39.8070805@ka9q.net>
	<1297874372.30541.29.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Phil Karn <karn@ka9q.net>,
	richard -rw- weinberger <richard.weinberger@gmail.com>,
	kaber@trash.net, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:45847 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752101Ab1BPSlg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Feb 2011 13:41:36 -0500
Received: by qwa26 with SMTP id 26so1579698qwa.19
        for <netdev@vger.kernel.org>; Wed, 16 Feb 2011 10:41:35 -0800 (PST)
In-Reply-To: <1297874372.30541.29.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/2/16 Eric Dumazet <eric.dumazet@gmail.com>:
> Le mercredi 16 f=C3=A9vrier 2011 =C3=A0 08:28 -0800, Phil Karn a =C3=A9=
crit :
>> On 2/16/11 8:10 AM, richard -rw- weinberger wrote:
>> > On Wed, Feb 16, 2011 at 4:58 PM, Phil Karn <karn@ka9q.net> wrote:
>> >> On 2/16/11 4:51 AM, richard -rw- weinberger wrote:
>> >>> On Wed, Feb 16, 2011 at 11:58 AM, Phil Karn <karn@ka9q.net> wrot=
e:
>> >>>> The range check on vlan_id in register_vlan_device is off by on=
e, and it
>> >>>> prevents the creation of a vlan interface for vlan ID 4095. (OS=
X allows
>> >>>> this, I checked.)
>> >>>
>> >>> Then OSX should fix their code. 4095 is reserved.
>> >> If it's reserved, then it's up to the user to reserve it.
>> > No.
>> > See:
>> > http://standards.ieee.org/getieee802/download/802.1Q-2005.pdf
>> Well, then I guess we all know better than the user. That's the Wind=
ows
>> Way...no, wait, I thought this is Linux.
>>
>> The fact is that I did encounter a misconfigured switch using vlan 4=
095,
>> and because of this off-by-one error I was unable to talk to it and =
fix it.
>>
>> I was hoping I wouldn't have to patch every new kernel I install.
> You can use an OSX gateway ;)
>
> If we allow ID 4095, then some users will complain we violate rules.
>
> Really you cannot push this patch in official kernel only to ease you=
r
> life ;)

The idea is that you don't have to use ID 4095 and if you don't -
nothing's broken by just allowing it. The same goes with ID 0 - it's
defined to be 802.1p packet, but people do use it as normal VLAN
(especially with hardware that can cope with only small number of
VLANs at once).

Allowing it but with a big fat warning in logs is even better: "You
want your network broken? Sure, can do, but you have been warned."

Best Regards,
Micha=C5=82 Miros=C5=82aw
