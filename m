From: Jesse Gross <jesse@nicira.com>
Subject: Re: sky2, vlan and nat/masquerading
Date: Thu, 17 Mar 2011 12:23:48 -0700
Message-ID: <AANLkTikeVWuDMhws4JX0S+WhKFja8zU_2ZY3KZZUAXks@mail.gmail.com>
References: <20110309181522.61ca1cc7@leda.vpn.lugor.de> <AANLkTi=AJJA0d0=CFuS66=+O6b80Ejj0w3NfKQ+OWzsK@mail.gmail.com>
 <20110314111105.5a62e092@leda.vpn.lugor.de> <AANLkTikXBz6ZpuSgqaAV-=Jr3qtDQ3T_We42R65Sd20O@mail.gmail.com>
 <20110315085326.1a1019aa@leda.vpn.lugor.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Christian Hesse <mail@eworm.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:65350 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753726Ab1CQTYJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Mar 2011 15:24:09 -0400
Received: by vxi39 with SMTP id 39so2931880vxi.19
        for <netdev@vger.kernel.org>; Thu, 17 Mar 2011 12:24:08 -0700 (PDT)
In-Reply-To: <20110315085326.1a1019aa@leda.vpn.lugor.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 15, 2011 at 12:53 AM, Christian Hesse <mail@eworm.de> wrote=
:
> On Mon, 14 Mar 2011 18:55:17 -0700 Jesse Gross <jesse@nicira.com> wro=
te:
>> On Mon, Mar 14, 2011 at 3:11 AM, Christian Hesse <mail@eworm.de> wro=
te:
>> > Ok, let me explain step by step:
>>
>> Thank you, this helps a lot in understanding your setup.
>>
>> >
>> > * Host sends icmp echo request (172.16.0.21 -> 192.168.100.3) to r=
outer
>> > =A0172.16.0.1, the packet is untagged.
>> > * Switch receives the packet on native interface with vid 2, tags =
it and
>> > sends it to the trunk)
>> > * Netbook receives the packet from trunk, untags it an queues it t=
o vlan
>> > =A0interface 2.
>> > * Netbook nats the packet (192.168.x.140 > 192.168.100.3), tags it=
 with
>> > vlan 2 and sends it to the trunk.
>>
>> For clarity, I'm assuming that this is supposed to be vlan 1?
>
> Sorry, little typo. Yes, you are right.
>
>> > * Switch receives the packet from trunk, untags it and sends it to=
 native
>> > =A0interface with vlan 1.
>> > * The packet and its answer (192.168.100.3 -> 192.168.x.140) make =
their
>> > way through the network.
>> > * Switch receives the icmp echo reply on native interface with vla=
n 1,
>> > tags it and sends it to the trunk
>> > * Netbook receives the packet from trunk, untags it an queues it t=
o vlan
>> > =A0interface 1.
>> > * Netbooks restores the original addresses from nat (192.168.100.3=
 ->
>> > =A0172.16.0.21), _tags_it_with_vlan_0_, tags it with vlan 2 and se=
nds it to
>> > the trunk
>>
>> Can you capture a packet trace on the netbook's Ethernet interface t=
o
>> see what it thinks it is sending?
>
> Ok, I have two traces for you: from the vlan interface and from the n=
ative
> interface. First ping to 172.16.0.65 is ok, second one to 192.168.100=
=2E3 fails.
>
> Please don't be confused, vlan 1 is vlan 3 this time and addresses
> changed a little bit. ;)

Hmm, it's pretty interesting that the extra vlan tag magically
appears.  I'll have to reproduce it to investigate further, as the
source isn't readily obvious to me.  You said that if you swap out a
different NIC but keep everything else the same the problem goes away?
 That also is strange because the packet capture should take place
before the driver.

Can you try using ethtool to turn off txvlan and see if that makes a di=
fference?
