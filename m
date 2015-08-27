From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v2] bridge: vlan: allow to suppress local mac
 install for all vlans
Date: Wed, 26 Aug 2015 21:57:19 -0700
Message-ID: <55DE98AF.8000503@cumulusnetworks.com>
References: <1440549295-3979-1-git-send-email-razor@blackwall.org> <20150825.194222.390859854071446877.davem@davemloft.net> <E065D3DC-6CBC-4625-8800-5133E21C5483@cumulusnetworks.com> <20150825.230641.773630246486190390.davem@davemloft.net> <AB16F445-DCA7-437E-B6E1-B70FDC63E55A@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	vyasevic@redhat.com, toshiaki.makita1@gmail.com,
	stephen@networkplumber.org, bridge@lists.linux-foundation.org,
	wkok@cumulusnetworks.com
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:36308 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751555AbbH0E5j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Aug 2015 00:57:39 -0400
Received: by pacgr6 with SMTP id gr6so11792308pac.3
        for <netdev@vger.kernel.org>; Wed, 26 Aug 2015 21:57:38 -0700 (PDT)
In-Reply-To: <AB16F445-DCA7-437E-B6E1-B70FDC63E55A@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/26/15, 4:33 AM, Nikolay Aleksandrov wrote:
>> On Aug 25, 2015, at 11:06 PM, David Miller <davem@davemloft.net> wro=
te:
>>
>> From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
>> Date: Tue, 25 Aug 2015 22:28:16 -0700
>>
>>> Certainly, that should be done and I will look into it, but the
>>> essence of this patch is a bit different. The problem here is not
>>> the size of the fdb entries, it=E2=80=99s more the number of them -=
 having
>>> 96000 entries (even if they were 1 byte ones) is just way too much
>>> especially when the fdb hash size is small and static. We could wor=
k
>>> on making it dynamic though, but still these type of local entries
>>> per vlan per port can easily be avoided with this option.
>> 96000 bits can be stored in 12k.  Get where I'm going with this?
>>
>> Look at the problem sideways.
> Oh okay, I misunderstood your previous comment. I=E2=80=99ll look int=
o that.
>
I just wanted to add the other problems we have had with keeping these=20
macs (mostly from userspace POV):
- add/del netlink notification storms
- and large netlink dumps

In addition to in-kernel optimizations, will be nice to have a solution=
=20
that reduces the burden on userspace. That will need a newer netlink=20
dump format for fdbs. Considering all the changes needed, Nikolays patc=
h=20
seems less intrusive.
