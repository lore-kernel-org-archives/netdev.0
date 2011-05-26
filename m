From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [RFC Patch] bonding: move to net/ directory
Date: Thu, 26 May 2011 16:25:16 +0200
Message-ID: <BANLkTikrsr5sZ4aZ5aEmfBSvPE0mEL8g0g@mail.gmail.com>
References: <BANLkTimkxi0BofJYv_tRj8Et+OZFu+VfBw@mail.gmail.com>
 <20110523151336.GF21309@gospo.rdu.redhat.com> <BANLkTikT2HJyGb_4BOF+Ds1AAcJV+HVQ-w@mail.gmail.com>
 <20110524163323.GB28521@hmsreliant.think-freely.org> <BANLkTinoRXmEAp0mbZdxSmMbntsE-QeRsQ@mail.gmail.com>
 <20110525152023.GC11867@hmsreliant.think-freely.org> <BANLkTin2HaYjHgGACkwvKwuY-Y_e3+r3JQ@mail.gmail.com>
 <20110526135053.GB12617@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?ISO-8859-1?Q?Am=E9rico_Wang?= <xiyou.wangcong@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Jay Vosburgh <fubar@us.ibm.com>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f181.google.com ([209.85.216.181]:39621 "EHLO
	mail-qy0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932544Ab1EZOZg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 May 2011 10:25:36 -0400
Received: by qyg14 with SMTP id 14so412603qyg.19
        for <netdev@vger.kernel.org>; Thu, 26 May 2011 07:25:36 -0700 (PDT)
In-Reply-To: <20110526135053.GB12617@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/5/26 Neil Horman <nhorman@tuxdriver.com>:
> On Thu, May 26, 2011 at 05:32:08PM +0800, Am=E9rico Wang wrote:
>> I don't think other drivers are supposed to use this function to reg=
ister
>> a packet handler, which is an important difference from my view.
> Note you just referred to the bridge/bond and vlan code as 'drivers' =
:). =A0And
> why is that function the gating factor? =A0Why not register_netdev? =A0=
or
> netif_receive_skb or dev_add_pack? =A0They all relate to the creation=
 of device
> interface and the reception of network data.
>
> The fact is, bonding/bridging/vlans/tunnels/etc all have aspects that
> make them more than just drivers. =A0They are where they are for a my=
rriad of
> reasons. =A0Moving them around changes their location, but does _noth=
ing_ about
> the underlying fact that they're driver code plus other stuff, and as=
 such
> provides no real advantage in terms of organization.

If you want to draw a line between net/ and drivers/net I propose
following idea:

net/ - everything that is about networking (or library for it) and
interacts only within the system (kernel<->user, or in-kernel)
drivers/net/ - everything that is a connecting point between the
system and external world - be it hardware, other VMs or hypervisor.

net/ would include wireless stack, all kinds of loopback devices,
tunnels (incl. vlan), bridging, bonding, tuntap, etc.
drivers/net/ would keep only what is hardware or external ABI dependent

Just my 2 cents (3 grosze ;-).

Best Regards,
Micha=B3 Miros=B3aw
