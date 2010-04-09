From: Laurent Chavey <chavey@google.com>
Subject: Re: [PATCH 1/1] add ethtool loopback support
Date: Fri, 9 Apr 2010 09:43:59 -0700
Message-ID: <x2o97949e3e1004090943o4b6b29e5pd261e2cb4c7f421d@mail.gmail.com>
References: <pvmbpdtn8yh.fsf@chavey.mtv.corp.google.com> <1270751373.5055.22.camel@achroite.uk.solarflarecom.com>
	<w2i97949e3e1004081217jdeca953dz162c62b61c0e8f72@mail.gmail.com>
	<1270755356.5055.23.camel@achroite.uk.solarflarecom.com> <j2r97949e3e1004081543h6258125dm60083556ff28fa88@mail.gmail.com>
	<4BBE78E2.2000709@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <bhutchings@solarflare.com>, davem@davemloft.net,
	netdev@vger.kernel.org, therbert@google.com
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:39002 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753128Ab0DIQod convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Apr 2010 12:44:33 -0400
Received: from hpaq1.eem.corp.google.com (hpaq1.eem.corp.google.com [10.3.21.1])
	by smtp-out.google.com with ESMTP id o39GiV2V015443
	for <netdev@vger.kernel.org>; Fri, 9 Apr 2010 09:44:31 -0700
Received: from gxk26 (gxk26.prod.google.com [10.202.11.26])
	by hpaq1.eem.corp.google.com with ESMTP id o39GiQsF027851
	for <netdev@vger.kernel.org>; Fri, 9 Apr 2010 18:44:30 +0200
Received: by gxk26 with SMTP id 26so1852314gxk.17
        for <netdev@vger.kernel.org>; Fri, 09 Apr 2010 09:44:25 -0700 (PDT)
In-Reply-To: <4BBE78E2.2000709@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

isn't the existing ETHTOOL_TEST ioctl use for something like self test =
?

the intent of this patch is to enable a mode whereby one could run
netperf / iperf and other application  and have the packets sent and
received by the driver.


On Thu, Apr 8, 2010 at 5:46 PM, Jeff Garzik <jeff@garzik.org> wrote:
> On 04/08/2010 06:43 PM, Laurent Chavey wrote:
>>
>> On Thu, Apr 8, 2010 at 12:35 PM, Ben Hutchings
>> <bhutchings@solarflare.com> =A0wrote:
>>>
>>> On Thu, 2010-04-08 at 12:17 -0700, Laurent Chavey wrote:
>>>>
>>>> On Thu, Apr 8, 2010 at 11:29 AM, Ben Hutchings
>>>> <bhutchings@solarflare.com> =A0wrote:
>>>>>
>>>>> On Thu, 2010-04-08 at 10:35 -0700, chavey@google.com wrote:
>>>
>>> [...]
>>>>>>
>>>>>> +enum ethtool_loopback_type {
>>>>>> + =A0 =A0 ETH_MAC =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =3D 0x00000001=
,
>>>>>> + =A0 =A0 ETH_PHY_INT =A0 =A0 =A0 =A0 =A0 =A0 =3D 0x00000002,
>>>>>> + =A0 =A0 ETH_PHY_EXT =A0 =A0 =A0 =A0 =A0 =A0 =3D 0x00000004
>>>>>> +};
>>>>>
>>>>> [...]
>>>>>
>>>>> There are many different places you can loop back within a MAC or=
 PHY,
>>>>> not to mention bypassing the MAC altogether. =A0See
>>>>> drivers/net/sfc/mcdi_pcol.h, starting from the line
>>>>> '#define MC_CMD_LOOPBACK_NONE 0'. =A0I believe we implement all o=
f those
>>>>> loopback modes on at least one board.
>>>>>
>>>>> Also are these supposed to be an enumeration or flags? =A0In theo=
ry you
>>>>
>>>> those are enums that can be or together.
>>>
>>> I.e. they are flags. =A0So how do you answer this:
>>>
>>>>> could use wire-side and host-side loopback at the same time if th=
ey
>>>>> don't overlap, but it's probably too much trouble to bother with.=
 =A0Any
>>>>> other combination is meaningless.
>>
>> since the intent is to enable the sending and receiving of packets a=
t
>> the hw/driver interfaces, a simple loopback mode on/off is sufficien=
t
>> and the ethtool_loopback_type are not necessary. the implementor can
>> choose
>> how to implement the loopback. From drivers/net/sfc/mcdi_pcol.h it i=
s
>> clear
>> that unless ethtool_loopback_type as defined are meaningless.
>
> If an off/on switch is sufficient, the existing ethtool flags interfa=
ce
> should work just fine.
>
> =A0 =A0 =A0 =A0Jeff
>
>
>
>
