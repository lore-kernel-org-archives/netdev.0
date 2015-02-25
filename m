From: Michael Kazakov <michael@marathonbet.ru>
Subject: Re: Packet dropps in virtual tap interface
Date: Wed, 25 Feb 2015 13:11:00 +0300
Message-ID: <54ED9FB4.8000508@marathonbet.ru>
References: <54EC24FF.3000407@marathonbet.ru> <54EC25E3.5050602@marathonbet.ru> <54ECAEF4.1060602@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Rick Jones <rick.jones2@hp.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.marathonbet.ru ([194.9.2.180]:54746 "EHLO
	mx0.marathonbet.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752670AbbBYKLC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2015 05:11:02 -0500
In-Reply-To: <54ECAEF4.1060602@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Similar to the increase TX queue to 10,000 on tap interface solved my=20
problem. I will say more accurately after the end of the week when we=20
will have the maximum load.
On 24/02/15 20:03, Rick Jones wrote:
> On 02/23/2015 11:18 PM, Michael Kazakov wrote:
>>
>>
>> Hello. We use our highly load system in OpenStack environment. And f=
aced
>> with serious problems in network highload guests. At a relatively hi=
gh
>> CPU load of hypervisor (40-60%) virtual network interfaces of this
>> guests starts to droppart of the packets. We use for virtualization
>> qemu-kvm with vhost driver: "... -netdev
>> tap,fd=3D30,id=3Dhostnet0,vhost=3Don,vhostfd=3D31 -device
>> virtio-net-pci,netdev=3Dhostnet0,id=3Dnet0,mac=3Dfa:16:3e:86:67:7b,b=
us=3Dpci.0,addr=3D0x3...".=20
>>
>>
>>
>> The problem can be seen with the ifconfig utility:
>> tape4009073-0b Link encap:Ethernet  HWaddr fe:16:3e:86:67:7b
>>            inet6 addr: fe80::fc16:3eff:fe86:677b/64 Scope:Link
>>            UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
>>            RX packets:1587622634 errors:0 dropped:0 overruns:0 frame=
:0
>>            TX packets:1484106438 errors:0 dropped:460259 overruns:0
>> carrier:0
>>            collisions:0 txqueuelen:500
>>            RX bytes:877878711500 (877.8 GB)  TX bytes:3071846828531 =
(3.0
>> TB)
>>
>> Could you do a little look at our problem and give advice which
>> direction to continue our investigation?
>
> If I recall the OpenStack plumbing correctly, the TX direction on the=
=20
> tap device is inbound to the instance.  You could, I suppose, try=20
> increasing the size of the txqueuelen via ifconfig, but you may want=20
> to triple check that the KVM I/O thread (?) isn't running at 100%.=20
> Particularly if when you say the hypervisor is running at 40-60% CPU=20
> utilization you mean overall CPU utilization of a multiple CPU system=
=2E
>
> I'm assuming that in broad handwaving terms, the TX queue of the tap=20
> device is behaving something like the SO_RCVBUF of a UDP socket would=
=20
> in a "normal"  system - if the VM (tap device case) or receiving=20
> process (UDP socket case) is held-up for a little while, that buffer=20
> is there to try to pick-up the slack.  If the VM is held-off from=20
> running long enough that queue will overflow and traffic will be drop=
ped.
>
> That might be the "raising the bridge" side of things.  The "lower th=
e=20
> river" side might be to find-out why and for how long the VM is being=
=20
> held-off from running and see if you can address that.
>
> rick jones
>

--=20
=D0=A1 =D1=83=D0=B2=D0=B0=D0=B6=D0=B5=D0=BD=D0=B8=D0=B5=D0=BC,
=D0=9C=D0=B8=D1=85=D0=B0=D0=B8=D0=BB =D0=9A=D0=B0=D0=B7=D0=B0=D0=BA=D0=BE=
=D0=B2
=D0=A1=D1=82=D0=B0=D1=80=D1=88=D0=B8=D0=B9 =D1=81=D0=B8=D1=81=D1=82=D0=B5=
=D0=BC=D0=BD=D1=8B=D0=B9 =D0=B0=D0=B4=D0=BC=D0=B8=D0=BD=D0=B8=D1=81=D1=82=
=D1=80=D0=B0=D1=82=D0=BE=D1=80
OOO "=D0=A1=D0=9F=D0=9B=D0=90=D0=A2"
