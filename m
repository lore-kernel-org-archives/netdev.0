From: Jesse Brandeburg <jesse.brandeburg@gmail.com>
Subject: Re: [PATCH -v2] x86: increase NR_IRQS and nr_irqs
Date: Sun, 3 Jan 2010 19:06:11 -0800
Message-ID: <4807377b1001031906s6b1ee576jc021da2642bb4147@mail.gmail.com>
References: <4B347AEE.6030705@kernel.org> <20091228094707.GH24690@elte.hu>
	 <4B398ECD.1080506@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	NetDEV list <netdev@vger.kernel.org>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: Yinghai Lu <yinghai@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f188.google.com ([209.85.210.188]:49020 "EHLO
	mail-yx0-f188.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752072Ab0ADDGM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Jan 2010 22:06:12 -0500
In-Reply-To: <4B398ECD.1080506@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 28, 2009 at 9:08 PM, Yinghai Lu <yinghai@kernel.org> wrote:
> have a system with lots of igb and ixgbe, when iov/vf are enabled for
> them, we hit the limit of 3064.
>
> when system have 20 pcie installed, and one card have 2 functions, an=
d one
> function need 64 msi-x,
> =A0may need 20 * 2 * 64 =3D 2560 for msi-x
> but if iov and vf are enabled
> =A0may need 20 * 2 * 64 * 3 =3D 7680 for msi-x
> assume system with 5 ioapic, nr_irqs_gsi will be 120.
> NR_CPUS =3D 512, and nr_cpu_ids =3D 128
> will have NR_IRQS =3D 256 + 512 * 64 =3D 33024
> will have nr_irqs =3D 120 + 8 * 128 + 120 * 64 =3D 8824
>
> when SPARSE_IRQ is not set, there is no increase with data
> when NR_CPUS=3D128, and SPARSE_IRQ is set
> =A0 text =A0 =A0 =A0 =A0 =A0 =A0data =A0 =A0 bss =A0 =A0 =A0 =A0 =A0 =
=A0dec =A0 =A0 =A0 =A0 =A0 hex =A0 =A0filename
> 21837444 =A0 =A0 =A0 =A04216564 12480736 =A0 =A0 =A0 =A038534744 =A0 =
=A0 =A0 =A024bfe58 vmlinux.before
> 21837442 =A0 =A0 =A0 =A04216580 12480736 =A0 =A0 =A0 =A038534758 =A0 =
=A0 =A0 =A024bfe66 vmlinux.after
> when NR_CPUS=3D4096, and SPARSE_IRQ is set
> =A0 text =A0 =A0 =A0 =A0 =A0 =A0data =A0 =A0 bss =A0 =A0 =A0 =A0 =A0 =
=A0dec =A0 =A0 =A0 =A0 =A0 hex =A0 =A0filename
> 21878619 =A0 =A0 =A0 =A05610244 13415392 =A0 =A0 =A0 =A040904255 =A0 =
=A0 =A0 =A0270263f vmlinux.before
> 21878617 =A0 =A0 =A0 =A05610244 13415392 =A0 =A0 =A0 =A040904253 =A0 =
=A0 =A0 =A0270263d vmlinux.after
>
> -v2: update comments to address Ingo's concern
>
> Signed-off-by: Yinghai Lu <yinghai@kernel.org>

I'm not sure this is the best plan, but may be okay for now.  What
happens when all of your slots have 6 port 82599 ixgbe adapters in
them?  They are being made[1], as well as quad port 82576 igb
adapters, however I'm not fully sure of the SRIOV support of the
bridges being used on those adapters.

Is it on the table to (re-)design this subsystem to be a little more
dynamic?  There are probably examples in ppc64 or ia64 directories.
Every time you suggest a limit I can find a case where it won't be
enough.

[1] http://www.hotlavasystems.com/products_10gbe.html
