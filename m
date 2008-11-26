From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [BUG] linux-2.6.28-rc3 regression: IRQ smp_affinities not respected
Date: Wed, 26 Nov 2008 10:01:47 +0100
Message-ID: <492D107B.1060303@cosmosbay.com>
References: <C27F8246C663564A84BB7AB343977242151F4B18B5@IRVEXCHCCR01.corp.ad.broadcom.com> <491154C8.3040401@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux kernel <linux-kernel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: ut <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:40644 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751911AbYKZJBv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Nov 2008 04:01:51 -0500
In-Reply-To: <491154C8.3040401@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet a =E9crit :
> Michael Chan a =E9crit :
>> I believe this may be the patch that broke it:
>>
>> http://git.kernel.org/?p=3Dlinux/kernel/git/torvalds/linux-2.6.git;a=
=3Dcommit;h=3Dce6fce4295ba727b36fdc73040e444bd1aae64cd=20
>>
>>
>> I don't remember all the details, but the Broadcom 5708 chip is
>> affected because it does not support MSI per-vector masking.
>>
>> One way to get around is to disable MSI with bnx2 parameter
>> disable_msi=3D1.
>>

>=20
> I tried this MSI disabling and yes, it now works.
>=20
> 16:      42726        128        105        106         89        =20
> 89        145        152   IO-APIC-fasteoi   uhci_hcd:usb1, eth0, eth=
1
>=20

I believe the bnx2 driver doesnt work at all if !disable_msi (default s=
etting)

Doing a "echo 0 >/sys/devices/system/cpu/cpu1/online" just freeze netwo=
rk

No messages logged

If loaded with disable_msi=3D1, the cpu unplug works as expected.

Thats a pretty serious issue.


