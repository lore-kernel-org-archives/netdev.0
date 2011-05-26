From: =?UTF-8?Q?Am=C3=A9rico_Wang?= <xiyou.wangcong@gmail.com>
Subject: Re: [RFC Patch] bonding: move to net/ directory
Date: Thu, 26 May 2011 17:32:08 +0800
Message-ID: <BANLkTin2HaYjHgGACkwvKwuY-Y_e3+r3JQ@mail.gmail.com>
References: <BANLkTimkxi0BofJYv_tRj8Et+OZFu+VfBw@mail.gmail.com>
	<20110523151336.GF21309@gospo.rdu.redhat.com>
	<BANLkTikT2HJyGb_4BOF+Ds1AAcJV+HVQ-w@mail.gmail.com>
	<20110524163323.GB28521@hmsreliant.think-freely.org>
	<BANLkTinoRXmEAp0mbZdxSmMbntsE-QeRsQ@mail.gmail.com>
	<20110525152023.GC11867@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andy Gospodarek <andy@greyhouse.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Jay Vosburgh <fubar@us.ibm.com>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:36962 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757229Ab1EZJcJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 May 2011 05:32:09 -0400
Received: by iyb14 with SMTP id 14so468923iyb.19
        for <netdev@vger.kernel.org>; Thu, 26 May 2011 02:32:09 -0700 (PDT)
In-Reply-To: <20110525152023.GC11867@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 25, 2011 at 11:20 PM, Neil Horman <nhorman@tuxdriver.com> w=
rote:
> On Wed, May 25, 2011 at 08:43:21PM +0800, Am=C3=A9rico Wang wrote:
>> On Wed, May 25, 2011 at 12:33 AM, Neil Horman <nhorman@tuxdriver.com=
> wrote:
>> > This all sounds like change for the sake of change to me. =C2=A0I =
don't see any
>> > compelling argument for moving bonding (or bridging or vlans, etc)=
 around at
>> > all. =C2=A0All of these software drivers have feet in multple subs=
ystems, but that
>> > just means that theres not going to be a compelling argument to mo=
ve them any
>> > place, =C2=A0at least not without an immediate subsequent argument=
 that it really
>> > belonged back where it was. =C2=A0Unless you can show a solid bene=
fit to moving the
>> > code, I don't see why any reorganization is needed.
>>
>> Well, as a people who worked on bonding code, I have no problem to k=
now
>> bonding code is under drivers/net/, but for people who don't know th=
is, probably
>> net/ is the first place they want to search.
>>
> you've asked them?
>
> cd git/net-next-2.6
> find . -name '*bond*'

No, somone asked me why bonding is not in net/ and after some thinking,
I see no reasons myself (thus sent this patch).


>> The other similar thing is that pktgen is in net/core/ while netcons=
ole is in
>> drivers/net/, which seems a little strange too.
>>
> Its is, and loopback is in /drivers/net, as is tun-tap and xen-netfro=
nt (none of
> which touch actual hardware), as is slip and ppp, which are net drive=
rs, but
> only operate on non net hardware. ppoe is another example which opera=
tes on
> ethernet, but sits on top of a secondary physical device (and so has =
no real
> hardware itself). =C2=A0These could all arguably be moved to /net, be=
cause they have
> no real hardware, but are in drivers because they implement instances=
 of the net
> driver interface.
>
>> vlan vs macvlan is the third example.
>>
> yes, it is, macvlan, like you assert could be moved, but you could ju=
st as
> easily move vlan to /drivers because it implements an instance of the=
 net device
> driver interface.

Then I agree here.

>
> The bottom line is, sometimes things aren't black and white, they're =
gray. And
> we put code where it makes the most sense at the time. =C2=A0We move =
it when it
> makes sense to, but I don't hear any compelling argument to make that=
 move.
> Yes, we're not always consistent with where we put hardwareless drive=
rs, but to
> make a policy and shove everything to one place or another doesn't an=
y more
> sense. =C2=A0If we do that we either wind up with things that we thin=
k of as drivers
> in the /net directory, or we wind up with stuff thats really protocol=
 oriented
> in the /drivers directory. =C2=A0And if the major problem we solve by=
 doing so is
> making life easier for someone who otherwise wouldn't be able to find=
 said code
> with a quick grep or find operation, it really doesn't seem like its =
worthwhile
> to me
>

Well, the problem is our code organisation, if we could organize the co=
de
in a better way that would help grepping the code.

>> In short, there are three callers of netdev_rx_handler_register(), m=
acvlan,
>> bonding and bridge, only bridge code stays in net/ directory.
> Why is calling netdev_rx_handler_register a gating factor here?
>

I don't think other drivers are supposed to use this function to regist=
er
a packet handler, which is an important difference from my view.
