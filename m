From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCHv4] net: Add batman-adv meshing protocol
Date: Wed, 8 Sep 2010 16:37:17 -0700
Message-ID: <AANLkTim-jswWzG=H0AQP5Z3byxoR1uXoV-ZhdaZ7+Sqd@mail.gmail.com>
References: <1283646353-17811-1-git-send-email-sven.eckelmann@gmx.de>
	<201009082058.15533.sven.eckelmann@gmx.de>
	<AANLkTi=FVyLE6OHTd+_qDbzSLk6fY5j6wBOWkYA810Dj@mail.gmail.com>
	<201009082225.47498.sven.eckelmann@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: b.a.t.m.a.n@lists.open-mesh.org, Andi Kleen <andi@firstfloor.org>,
	davem@davemloft.net, netdev@vger.kernel.org,
	b.a.t.m.a.n@lists.open-mesh.net
To: Sven Eckelmann <sven.eckelmann@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:64310 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932159Ab0IHXhS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Sep 2010 19:37:18 -0400
Received: by iwn5 with SMTP id 5so452638iwn.19
        for <netdev@vger.kernel.org>; Wed, 08 Sep 2010 16:37:17 -0700 (PDT)
In-Reply-To: <201009082225.47498.sven.eckelmann@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 8, 2010 at 1:25 PM, Sven Eckelmann <sven.eckelmann@gmx.de> =
wrote:
>> > =A0* Does it allow to append extra header information to the packe=
t?
>> > =A0* Does it allow fragmentation of packets (not real fragmentatio=
n, but
>> > more single split)?
>>
>> I'm assuming that both of these questions are for tunneling. =A0Open
>> vSwitch currently supports a few different L2 over L3 tunneling
>> mechanisms and has a tunnel library that makes adding additional
>> protocols easy. =A0It probably can't do exactly what you need right =
now,
>> but it should be fairly easy to extend.
>
> Hm, low overhead tunneling is one of the main parts, but if you think=
 that it
> is easy to extend then fine.

I understand that tunneling needs to go in the kernel.  However, as I
said, several tunneling mechanisms already exist in Open vSwitch
(maybe one of them even already meets your needs) and adding another
one would certainly be less code than the approximately 9000 lines
that this patch entails.

>
>> > =A0* Does it allow to define outgoing patterns (on which attached =
interface
>> > =A0 goes the thing out again) on packet number or incoming device =
(the real
>> > =A0 hardware device it was coming in)?
>>
>> I'm not sure what you mean by "packet number". =A0It does allow you =
to
>> specify the output interface based on a number of factors, include t=
he
>> input device.
>
> It would mean that for example 5 packets goes over device 1, the next=
 5
> packets goes over

I'm assuming that those packets are from different higher level flows,
right?  Otherwise you will have significant reordering issues.
Assuming that is the case, then yes, this is possible and is how Open
vSwitch implements bonding purely in userspace.

>
>> > * directly influence the traffic flow, i.e., ARQ for broadcasts,
>
> Could you please comment on that one (taken from Mareks mail). Think =
about
> that one:
> =A0* A Broadcast packet must be send over wifi (adhoc)
> =A0* This packet is probably dropped due to some interferences. So ea=
ch node
> =A0 must transmit the broadcast more than one time to be (with a good=
 chance
> =A0 successful). This is quite essential on l2 based adhoc wifi mesh =
networks
> =A0 (as tests showed - but please ask Marek for the actual test setup=
s)

This isn't something that Open vSwitch currently has support for since
it expects the properties of Ethernet, which is best effort, and
assumes the upper layers will do any retransmission if desired.
However, I know that for lossy wireless networks sometimes this is not
sufficient.  Open vSwitch has a virtual port abstraction in the kernel
that works well for this type of application specific code and is
where I would expect you to put your tunneling protocol.  I suspect
that this may fit in there as well.  Again, I understand that there
are some areas where the existing Open vSwitch does not exactly fit
all of your needs.  However, I think that you will find that the parts
of the kernel that require extension are actually quite small and well
abstracted.
