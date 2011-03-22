From: Jesse Gross <jesse@nicira.com>
Subject: Re: bnx2 vlan issue
Date: Mon, 21 Mar 2011 19:05:09 -0700
Message-ID: <AANLkTik1JJO7mqxPzqfshMfH2JFUXn+yxbTqVdr4QDf6@mail.gmail.com>
References: <AANLkTik0BOuDj5wmfHabZx_OzXDROtDLR2qtqUqQu4ko@mail.gmail.com>
 <AANLkTi=rOjHZt_F01UfunrTm=2r1BO5QGFDeV9XyKX4G@mail.gmail.com>
 <AANLkTimAnHcoVDY_p8PqZLMJdMz2w7bMnSbOwzn4aR4i@mail.gmail.com> <AANLkTimJsBYefz3+3HgBgrHUR33g+TWuBp15E=VODohb@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Seblu <seblu@seblu.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:39635 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754767Ab1CVCFa convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Mar 2011 22:05:30 -0400
Received: by qwk3 with SMTP id 3so4647592qwk.19
        for <netdev@vger.kernel.org>; Mon, 21 Mar 2011 19:05:29 -0700 (PDT)
In-Reply-To: <AANLkTimJsBYefz3+3HgBgrHUR33g+TWuBp15E=VODohb@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 17, 2011 at 4:22 PM, Seblu <seblu@seblu.net> wrote:
> On Thu, Mar 17, 2011 at 8:16 PM, Jesse Gross <jesse@nicira.com> wrote=
:
>> On Thu, Mar 17, 2011 at 11:02 AM, Seblu <seblu@seblu.net> wrote:
>>> On Thu, Mar 17, 2011 at 3:51 PM, Seblu <seblu@seblu.net> wrote:
>>
>> It was a bug that it worked at all and whether it worked depended on
>> the hardware/firmware/driver. =A0If an interface is attached to a
>> bridge, the bridge takes all the packets received on that interface,
>> including vlan packets.
> ok i see.
>
>>
>> There are a few ways to setup vlans and bridging that work on all
>> kernels and with all NICs:
>>
>> * vlans on interface, bridges contain vlan devices. =A0This gives yo=
u a
>> bridge for each vlan.
> Except for untagged isn't it? This is why i fail. I need to have a
> bridge with the untagged vlan from an interface.
> Before 2.6.37 (with most of drivers/firmware/hardware i use) when a
> vlan is defined on an interface, for example eth0, eth0.15 show vlan1=
5
> frames and eth0 show untagged frames.
>
> I've tryed eth0.0, expecting to have untagged vlan, but this doesnt w=
ork.

eth0.0 will get packets that have a vlan tag with vid 0, some people
use it as just another vlan.

> How can I create a bridge with the untagged vlan from an interface?
>
>> * bridge on interface, vlans on bridge device. =A0This gives you a
>> bridge with all packets and vlan devices can give you specific vlans=
=2E
> I cannot use this schema, i used bridge to bring together vnet
> interface and vlan interface.

I'm not sure I understand why you say you can't use this.  You can
combine vlans and bridging pretty much arbitrarily, including stacking
multiple layers.

>
>> * Use ebtables rules in the bridge to accept/reject certain packets =
as desired.
> I don't see how use ebtables to push untagged frame to a dedicated
> iface which can be added in a bridge.

You could have a bridge on the raw interface and connect all of the
VMs that need untagged traffic.  If you add an ebtables rule to reject
tagged traffic then vlan devices on the interface will continue to
work as before.
