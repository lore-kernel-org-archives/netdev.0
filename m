From: Ben Greear <greearb@candelatech.com>
Subject: =?UTF-8?Q?Re:_veth_regression_with_=22don=e2=80=99t_modify_ip=5fsum?=
 =?UTF-8?Q?med;_doing_so_treats_packets_with_bad_checksums_as_good.=22?=
Date: Thu, 7 Apr 2016 11:32:56 -0700
Message-ID: <5706A7D8.8090402@candelatech.com>
References: <56F463D6.7080406@candelatech.com>
 <CAM_iQpWv_iP1ZtsRQT0YsztMrf6rdaXN2V57PUu5oBe5kR56AQ@mail.gmail.com>
 <56F4810A.9060904@candelatech.com> <56F49036.8050902@candelatech.com>
 <56F490B2.3090603@candelatech.com>
 <CAKUBDd9TjFTvXSEL=+J02PVndNG-gcrMOpRo_MFp4J-oOnLrvQ@mail.gmail.com>
 <56F4BFF1.8010806@candelatech.com>
 <CAM_iQpUaBD-HmHVAcEBCRw38PbecjYk2to+DO9TNkLY93u2_NA@mail.gmail.com>
 <56F4C8FD.7030907@candelatech.com>
 <CAM_iQpWwch3+6u+X0DBGyVSWttd7Nz2COdmq2q=G9BxisW52bA@mail.gmail.com>
 <56F5A618.9070206@candelatech.com>
 <CAKUBDd844=BTpK2B2izzRGqwKQV5RtsFAO9nFQ5CJqDENLFW5A@mail.gmail.com>
 <56F5BA45.2030706@candelatech.com>
 <CAKUBDd8FGh3mhDmoyH70WvNGyofPVbjdROPKzenm+6DLfALyqg@mail.gmail.com>
 <56F5CDE4.7010306@candelatech.com>
 <CAKUBDd_2sC45FW72g1nWzM0k0+EeBUk0LoOMzVwuBfLWHUh-KA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	netdev <netdev@vger.kernel.org>, Evan Jones <ej@evanjones.ca>,
	Cong Wang <cwang@twopensource.com>
To: Vijay Pandurangan <vijayp@vijayp.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.candelatech.com ([208.74.158.173]:35485 "EHLO
	mail2.candelatech.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757276AbcDGSc5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Apr 2016 14:32:57 -0400
In-Reply-To: <CAKUBDd_2sC45FW72g1nWzM0k0+EeBUk0LoOMzVwuBfLWHUh-KA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/07/2016 08:11 AM, Vijay Pandurangan wrote:
> On Fri, Mar 25, 2016 at 7:46 PM, Ben Greear <greearb@candelatech.com>=
 wrote:
>> A real NIC can either do hardware checksums, or it cannot.  If it
>> cannot, then the host must do it on the CPU for both transmit and
>> receive.
>>
>> Veth is not a real NIC, and it cannot do hardware checksum offloadin=
g.
>>
>> So, we either lie and pretend it does, or we eat massive amounts
>> of CPU usage to calculate and check checksums when sending across
>> a veth pair.
>>
>
> That's a good point. Does anyone know what the overhead actually is t=
hese days?

You could try setting up a system with ixgbe or similar, and then manua=
lly
disable csum offload using ethtool, and see how that performs in compar=
ison
to hardware offload?

>> But, if I am purposely corrupting a frame destined for veth, then th=
e only
>> reason
>> I would want the stack to check the checksums is if I were testing m=
y own
>> stack's checksum logic, and that seems to be a pretty limited use.
>
>
> In the common case you're 100% right.  OTOH, there's something
> disconcerting about an abstraction layer lying and behaving
> unexpectedly.  Most traffic that originates on a machine can have its
> checksums safely ignored.  Whatever the reason is (maybe, as you say
> you're testing checksums =E2=80=93 on the other hand maybe there's a =
bug in
> your code somewhere), I really feel like we should try to figure out =
a
> way to ensure that this optimization is at the very least opt-in=E2=80=
=A6

I'm fine with allowing a user to force software-csum on veth devices
if someone wants to code that up, but forcing sw-csum for local frames
on veth devices should be disabled by default.

Thanks,
Ben

--=20
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
