From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [BUG] linux-2.6.28-rc3 regression: IRQ smp_affinities not
 respected
Date: Wed, 26 Nov 2008 09:14:52 -0800
Message-ID: <1227719692.13189.7.camel@HP1>
References: <C27F8246C663564A84BB7AB343977242151F4B18B5@IRVEXCHCCR01.corp.ad.broadcom.com>
 <491154C8.3040401@cosmosbay.com> <492D107B.1060303@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "linux kernel" <linux-kernel@vger.kernel.org>,
	"Linux Netdev List" <netdev@vger.kernel.org>
To: "Eric Dumazet" <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4825 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753276AbYKZRR4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Nov 2008 12:17:56 -0500
In-Reply-To: <492D107B.1060303@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Wed, 2008-11-26 at 01:01 -0800, Eric Dumazet wrote:
> Eric Dumazet a =C3=A9crit :
> > Michael Chan a =C3=A9crit :
> >> I believe this may be the patch that broke it:
> >>
> >> http://git.kernel.org/?p=3Dlinux/kernel/git/torvalds/linux-2.6.git=
;a=3Dcommit;h=3Dce6fce4295ba727b36fdc73040e444bd1aae64cd=20
> >>
> >>
> >> I don't remember all the details, but the Broadcom 5708 chip is
> >> affected because it does not support MSI per-vector masking.
> >>
> >> One way to get around is to disable MSI with bnx2 parameter
> >> disable_msi=3D1.
> >>
>=20
> >=20
> > I tried this MSI disabling and yes, it now works.
> >=20
> > 16:      42726        128        105        106         89        =20
> > 89        145        152   IO-APIC-fasteoi   uhci_hcd:usb1, eth0, e=
th1
> >=20
>=20
> I believe the bnx2 driver doesnt work at all if !disable_msi (default=
 setting)
>=20
> Doing a "echo 0 >/sys/devices/system/cpu/cpu1/online" just freeze net=
work
>=20
> No messages logged
>=20
> If loaded with disable_msi=3D1, the cpu unplug works as expected.
>=20
> Thats a pretty serious issue.
>
Yes, that's the same issue and it is serious.  If MSI is being delivere=
d
to CPU 1 and you then take CPU 1 offline, the MSI will not be delivered
to another CPU.

I think I can detect this problem in bnx2_timer() and try to recover.
I'll post a patch when I have something ready.  Thanks.


