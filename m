From: =?UTF-8?Q?Am=C3=A9rico_Wang?= <xiyou.wangcong@gmail.com>
Subject: Re: [RFC Patch] bonding: move to net/ directory
Date: Wed, 25 May 2011 20:32:43 +0800
Message-ID: <BANLkTi=UCH8+ZVFwZ96YvFuDqDLwq8ihkQ@mail.gmail.com>
References: <BANLkTimkxi0BofJYv_tRj8Et+OZFu+VfBw@mail.gmail.com>
	<20110523151336.GF21309@gospo.rdu.redhat.com>
	<BANLkTikT2HJyGb_4BOF+Ds1AAcJV+HVQ-w@mail.gmail.com>
	<20110524150340.GH21309@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Jay Vosburgh <fubar@us.ibm.com>
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:54449 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755288Ab1EYMco convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 May 2011 08:32:44 -0400
Received: by iwn34 with SMTP id 34so6393571iwn.19
        for <netdev@vger.kernel.org>; Wed, 25 May 2011 05:32:43 -0700 (PDT)
In-Reply-To: <20110524150340.GH21309@gospo.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 24, 2011 at 11:03 PM, Andy Gospodarek <andy@greyhouse.net> =
wrote:
> On Tue, May 24, 2011 at 10:00:23PM +0800, Am=C3=A9rico Wang wrote:
>> On Mon, May 23, 2011 at 11:13 PM, Andy Gospodarek <andy@greyhouse.ne=
t> wrote:
>> > On Mon, May 23, 2011 at 08:45:14PM +0800, Am=C3=A9rico Wang wrote:
>> >> Hello, Jay, Andy,
>> >>
>> >> Is there any peculiar reason that bonding code has to stay
>> >> in drivers/net/ directory?
>> >>
>> >> Since bonding and bridge are somewhat similar, both of
>> >> which are used to "bond" two or more devices into one,
>> >> and bridge code is already in net/bridge/, so I think it also
>> >> makes sense to move bonding code into net/bonding/ too.
>> >>
>> >> This could also help to grep the source more easily. :)
>> >>
>> >> What do you think about the patch below?
>> >> (Note, this patch is against net-next-2.6.)
>> >>
>> >
>> > I would rather keep the code for bonding in drivers/net since it i=
s
>> > really a pure device (though not directly tied to any specific
>> > hardware) rather than a device + forwarding or management code.
>>
>> Is this a reason strong enough to leave it to drivers/net/ ?
>> I think it is generic enough to be moved to net/ directory... :-/
>>
>
> I think the distinction is an important one and is one of the main
> reasons why I would like to see bonding stay in drivers/net.
>

Is this a rule that we judge if a piece of code should be in net/
or drivers/net/ ? For me, that big difference between these
two directory is clearly if the code is generic or hardware/platform
independent.

>> >
>> > It has bothered me for a long time that the code just to manage th=
e VLAN
>> > and bridge devices sits outside of drivers/net, but I've never pro=
posed
>> > a patch to move the files as I suspect the maintainers of that cod=
e
>> > would like to keep it all together. =C2=A0Maybe it is time to do t=
hat.
>> >
>>
>> You mean move net/8021q/ to drivers/net/8021q/ ?
>>
>
> No. =C2=A0I'm talking about the parts in the bridging and vlan code t=
hat
> specifically setup devices, not all of the code. =C2=A0I would be hap=
pier
> if code that created objects of type net_device_ops all lived in
> drivers/net. =C2=A0Then all the drivers (real, stacked, or virtual) a=
re in
> the same place.

This would make grepping the source code more harder
than it is, at least now we can grepping all bridge source code
in net/bridge/, for example.

Actually the vlan case you mentioned can be another example
to show that to moving bonding code into net/ makes sense.
