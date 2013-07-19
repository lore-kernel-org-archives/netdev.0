From: Cosmin GIRADU <cosmin.giradu@rcs-rds.ro>
Subject: Re: BCM5721 transmit queue 0 timed out
Date: Fri, 19 Jul 2013 10:24:34 +0300
Message-ID: <51E8E9B2.90902@rcs-rds.ro>
References: <51E7AB9D.3010803@rcs-rds.ro> <51E81982.5090200@broadcom.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="pr84bBQhETCEWjPD2gisV3UV11cFFDsRH"
Cc: Linux Net Dev <netdev@vger.kernel.org>
To: Nithin Nayak Sujir <nsujir@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailproxy.rcs-rds.ro ([212.54.120.14]:34850 "EHLO
	mailproxy.rcs-rds.ro" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759770Ab3GSHYf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jul 2013 03:24:35 -0400
In-Reply-To: <51E81982.5090200@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--pr84bBQhETCEWjPD2gisV3UV11cFFDsRH
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 18/07/13 19:36, Nithin Nayak Sujir wrote:
>
> On 7/18/2013 1:47 AM, Cosmin GIRADU wrote:
>> Hi,
>>
>> I need some help with the following situation:
>>
>> We keep getting random lockups on our BCM5721 cards (most of them are
>> LOMs, multiple machines, running multiple kernel versions between 3.4
>> and 3.10.1), when the traffic is high (above 300Mbit/s). The hardware =
is
>> dual port "Tigon3 [partno(BCM95721) rev 4201] (PCI Express)" with 5750=

>> chip inside.
>
> Cosmin,
> Can you send the full register dump from the kernel log?
This is what I have in the kernel log:

tg3 0000:01:00.0 eth0: Tigon3 [partno(BCM95721) rev 4201] (PCI Express)
MAC address 00:1a:64:6d:e7:57
tg3 0000:01:00.0 eth0: attached PHY is 5750 (10/100/1000Base-T Ethernet)
(WireSpeed[1], EEE[0])
tg3 0000:01:00.0 eth0: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[1] TSOcap[1]=

tg3 0000:01:00.0 eth0: dma_rwctrl[76180000] dma_mask[64-bit]
tg3 0000:03:00.0 eth1: Tigon3 [partno(BCM95721) rev 4201] (PCI Express)
MAC address 00:1a:64:6d:e7:58
tg3 0000:03:00.0 eth1: attached PHY is 5750 (10/100/1000Base-T Ethernet)
(WireSpeed[1], EEE[0])
tg3 0000:03:00.0 eth1: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[1] TSOcap[1]=

tg3 0000:03:00.0 eth1: dma_rwctrl[76180000] dma_mask[64-bit]
tg3 0000:01:00.0: irq 42 for MSI/MSI-X
tg3 0000:03:00.0: irq 43 for MSI/MSI-X

It's the kernel log from the same machine, after init the NIC names get
translated like this: eth0 -> eth2, eth1 -> eth3, from udev.

If you meant something else, please instruct me on how to obtain it.

>
> Also can you give more details about the system and the traffic? Is it
> reproducible with something like netperf?
We use the system as a qos router with ~6k classes per interface, 40kpps
to 70kpps symmetric,
and the only way I can describe the flows is "completely random".

>
> Nithin.
>
Thank you!

>
>> The lockups look like this:
>>
>> ------------[ cut here ]------------
>> WARNING: at net/sched/sch_generic.c:255 dev_watchdog+0x25a/0x270()
>> NETDEV WATCHDOG: eth2 (tg3): transmit queue 0 timed out
>> Modules linked in: ip_gre ip_tunnel gre loop processor thermal_sys
>> i2c_i801 lpc_ich coretemp button mfd_core
>> CPU: 1 PID: 0 Comm: swapper/1 Not tainted 3.10.1.htb.104 #1
>> Hardware name: IBM IBM System x3250 -[43654BG]-/M31ip, BIOS IBM BIOS
>> Version 1.33-[G9E133AUS-1.33]- 08/28/2007
>>   ffffffff81781f16 ffff88003fd03d98 ffffffff8152f6eb ffff88003fd03dd8
>>   ffffffff8103659b ffff88003fd03dd8 ffff88003d3f0000 ffff88003e103d00
>>   0000000000000005 0000000000000001 ffff88003e0a9428 ffff88003fd03e38
>> Call Trace:
>>   <IRQ>  [<ffffffff8152f6eb>] dump_stack+0x19/0x1e
>>   [<ffffffff8103659b>] warn_slowpath_common+0x6b/0xa0
>>   [<ffffffff81036671>] warn_slowpath_fmt+0x41/0x50
>>   [<ffffffff81471d6a>] dev_watchdog+0x25a/0x270
>>   [<ffffffff81471b10>] ? __netdev_watchdog_up+0x80/0x80
>>   [<ffffffff8104312c>] call_timer_fn+0x2c/0x90
>>   [<ffffffff81043369>] run_timer_softirq+0x1d9/0x1f0
>>   [<ffffffff8103d351>] __do_softirq+0xd1/0x1a0
>>   [<ffffffff8103d4c5>] irq_exit+0x65/0x80
>>   [<ffffffff81024399>] smp_apic_timer_interrupt+0x69/0xa0
>>   [<ffffffff81533b0a>] apic_timer_interrupt+0x6a/0x70
>>   <EOI>  [<ffffffff8100a126>] ? default_idle+0x6/0x10
>>   [<ffffffff8100a2f6>] arch_cpu_idle+0x16/0x20
>>   [<ffffffff8106afd5>] cpu_startup_entry+0xa5/0x200
>>   [<ffffffff818c57ce>] start_secondary+0x267/0x269
>> ---[ end trace d3a202af040f84f0 ]---
>> tg3 0000:01:00.0: tg3_stop_block timed out, ofs=3D1400 enable_bit=3D2
>> tg3 0000:01:00.0: tg3_stop_block timed out, ofs=3Dc00 enable_bit=3D2
>> tg3 0000:01:00.0: tg3_stop_block timed out, ofs=3D1400 enable_bit=3D2
>> tg3 0000:01:00.0: tg3_stop_block timed out, ofs=3Dc00 enable_bit=3D2
>>
>> As far as I can tell the "tg3_stop_block timed out" is thrown when the=

>> card is being reset after the hang timer expires and is quite harmless=

>> (hope I'm reading it right). However said hangs do tend to be more
>> frequent as the amount of traffic rises, and that does interfere with
>> operation.
>>
>> As a workaround, disabling scatter-gather on the offending cards stops=

>> the problem from reappearing, however I'd like to get to the bottom of=

>> this once and for all.
>>
>
> --=20
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


--=20

Cosmin GIRADU
OSS Engineer
RCS & RDS - Unified Services
Phone:  +40-31-400-6323
Mobile: +40-77-020-0858
http://www.rcs-rds.ro

=2E......................................................................=
=2E..
Privileged/Confidential Information may be contained in this message. If
you are not the addressee indicated in this message (or responsible for
delivery of the message to such person), you may not copy or deliver
this message to anyone. In such a case, you should destroy this message
and kindly notify the sender by reply e-mail.



--pr84bBQhETCEWjPD2gisV3UV11cFFDsRH
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.20 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQEcBAEBAgAGBQJR6OmyAAoJEKIzlqmspKc9h0EIAMnDfJaZ20LOJ7S8rvwY1/U8
4/KjIjm90BQ0IV2ffRX0JVcf6zDsVXAd5xrp4Y+NEE6mHcCyiPW5U2aP15Ya6ZWh
2RfNBvyRC5S1ihDM2wAa3PIxBlApbms7qdalxcg2SFND/xyG/IhJZwCAiBcgS6tr
n/YiyncFn/TRpfHIBsaJGMNLT+VJuh/lo/yAThlANi2LJBpBGEIh9ELoA78463Kb
/baR7XL7Ody5xIUrVPP7ORNC4kXMCjBPCfvIOzLHvot5zJuvlSvFhci9t7RR/Cn4
R/Q9rN7R7KMq8U8iHA+yQvHdzT+Gg54xhNvCKN5Vouvrv9K2P1QBKhA1wZzra4Q=
=3dkp
-----END PGP SIGNATURE-----

--pr84bBQhETCEWjPD2gisV3UV11cFFDsRH--
