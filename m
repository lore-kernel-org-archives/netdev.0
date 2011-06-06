From: =?UTF-8?Q?Am=C3=A9rico_Wang?= <xiyou.wangcong@gmail.com>
Subject: Re: [RFC Patch] bonding: move to net/ directory
Date: Tue, 7 Jun 2011 00:34:25 +0800
Message-ID: <BANLkTin4VyK3boPqDQnd+Dkv6==cHww9PA@mail.gmail.com>
References: <BANLkTimkxi0BofJYv_tRj8Et+OZFu+VfBw@mail.gmail.com>
	<20110523151336.GF21309@gospo.rdu.redhat.com>
	<BANLkTikT2HJyGb_4BOF+Ds1AAcJV+HVQ-w@mail.gmail.com>
	<20110524163323.GB28521@hmsreliant.think-freely.org>
	<BANLkTinoRXmEAp0mbZdxSmMbntsE-QeRsQ@mail.gmail.com>
	<20110525152023.GC11867@hmsreliant.think-freely.org>
	<BANLkTin2HaYjHgGACkwvKwuY-Y_e3+r3JQ@mail.gmail.com>
	<20110526135053.GB12617@hmsreliant.think-freely.org>
	<BANLkTikrsr5sZ4aZ5aEmfBSvPE0mEL8g0g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Jay Vosburgh <fubar@us.ibm.com>
To: =?UTF-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirqus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:51845 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751703Ab1FFQe0 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2011 12:34:26 -0400
Received: by iwn34 with SMTP id 34so3245505iwn.19
        for <netdev@vger.kernel.org>; Mon, 06 Jun 2011 09:34:26 -0700 (PDT)
In-Reply-To: <BANLkTikrsr5sZ4aZ5aEmfBSvPE0mEL8g0g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/5/26 Micha=C5=82 Miros=C5=82aw <mirqus@gmail.com>:
> 2011/5/26 Neil Horman <nhorman@tuxdriver.com>:
>> On Thu, May 26, 2011 at 05:32:08PM +0800, Am=C3=A9rico Wang wrote:
>>> I don't think other drivers are supposed to use this function to re=
gister
>>> a packet handler, which is an important difference from my view.
>> Note you just referred to the bridge/bond and vlan code as 'drivers'=
 :). =C2=A0And
>> why is that function the gating factor? =C2=A0Why not register_netde=
v? =C2=A0or
>> netif_receive_skb or dev_add_pack? =C2=A0They all relate to the crea=
tion of device
>> interface and the reception of network data.
>>
>> The fact is, bonding/bridging/vlans/tunnels/etc all have aspects tha=
t
>> make them more than just drivers. =C2=A0They are where they are for =
a myrriad of
>> reasons. =C2=A0Moving them around changes their location, but does _=
nothing_ about
>> the underlying fact that they're driver code plus other stuff, and a=
s such
>> provides no real advantage in terms of organization.
>
> If you want to draw a line between net/ and drivers/net I propose
> following idea:
>
> net/ - everything that is about networking (or library for it) and
> interacts only within the system (kernel<->user, or in-kernel)
> drivers/net/ - everything that is a connecting point between the
> system and external world - be it hardware, other VMs or hypervisor.
>
> net/ would include wireless stack, all kinds of loopback devices,
> tunnels (incl. vlan), bridging, bonding, tuntap, etc.
> drivers/net/ would keep only what is hardware or external ABI depende=
nt
>

I agree with this, IMHO this would help to organize the code better.
And currently only tuntap and bonding are still in net/ directory.

In any aspects, now we are mixing net/ and drivers/net/ currently,
which could be improved.

Thanks!
