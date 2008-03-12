From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: 2.6.25-rc5-mm1
Date: Wed, 12 Mar 2008 12:44:20 -0700
Message-ID: <20080312124420.3ba8c3d7.akpm@linux-foundation.org>
References: <20080311011434.ad8c8d7d.akpm@linux-foundation.org>
	<20080311202300.GA8957@vino.hallyn.com>
	<20080311133920.68dc410b.akpm@linux-foundation.org>
	<64bb37e0803121233v30d12a58i77a1e23fd02ea6f2@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: "Torsten Kaiser" <just.for.lkml@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:54466 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752087AbYCLToX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Mar 2008 15:44:23 -0400
In-Reply-To: <64bb37e0803121233v30d12a58i77a1e23fd02ea6f2@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 12 Mar 2008 20:33:02 +0100
"Torsten Kaiser" <just.for.lkml@googlemail.com> wrote:

> On Tue, Mar 11, 2008 at 9:39 PM, Andrew Morton
> <akpm@linux-foundation.org> wrote:
> >  > Quoting Andrew Morton (akpm@linux-foundation.org):
> >  > > ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.25-rc5/2.6.25-rc5-mm1/
> >  I suspect that fewer people are testing linux-next and -mm nowadays.  We
> >  should encourage them to do so, although given the general
> >  trainwreckishness of current mainline, this isn't really where our effort
> >  should be expended.
> 
> 2.6.25-rc3-mm1 worked nicely for me, but 2.6.25-rc5-mm1 does not boot.
> 
> dmesg:
> [    0.000000] Linux version 2.6.25-rc5-mm1 (root@treogen) (gcc
> version 4.2.3 (Gentoo 4.2.3 p1.0)) #1 SMP Wed Mar 12 19:51:41 CET 2008
> [    0.000000] Command line: earlyprintk=serial,ttyS0,115200
> console=ttyS0,115200 console=tty1 crypt_root=/dev/md1 sata_nv.swncq=1

So you aren't using netconsole.  I had a series of hangs yesterday which
went away when netconsole was disabled.  I think netconsole is still
busted.

> ...
>
> be reserved
> [    1.943656] system 00:0d: iomem range 0xfec00000-0xffffffff could
> not be reserved
> [    1.961251] PCI: Bridge: 0000:00:06.0
> [    1.964921]   IO window: disabled.
> [    1.968331]   MEM window: 0xeff00000-0xefffffff
> [    1.980903]   PREFETCH window: 0x00000000eef00000-0x00000000eeffffff
> [    1.987254] PCI: Bridge: 0000:00:0b.0
> [    2.000871]   IO window: e000-efff
> [    2.004283]   MEM window: 0xefe00000-0xefefffff
> [    2.022569]   PREFETCH window: disabled.
> [    2.026646] PCI: Bridge: 0000:00:0c.0
> [    2.030312]   IO window: disabled.
> [    2.040486]   MEM window: 0xefd00000-0xefdfffff
> [    2.045020]   PREFETCH window: disabled.
> [    2.050486] PCI: Bridge: 0000:00:0d.0
> [    2.062526]   IO window: disabled.
> [    2.065935]   MEM window: 0xefc00000-0xefcfffff
> [    2.082499]   PREFETCH window: disabled.
> [    2.086432] PCI: Bridge: 0000:00:0f.0
> [    2.092499]   IO window: d000-dfff
> [    2.102467]   MEM window: 0xefb00000-0xefbfffff
> [    2.107000]   PREFETCH window: 0x00000000e0000000-0x00000000e7ffffff
> [    2.122526] NET: Registered protocol family 2
> -> System hang, no reaction to the SysRq keys.
> 
> >From 2.6.25-rc3-mm1:
> [    1.505990] PCI: Bridge: 0000:00:06.0
> [    1.509654]   IO window: disabled.
> [    1.513064]   MEM window: 0xeff00000-0xefffffff
> [    1.515228]   PREFETCH window: 0x00000000eef00000-0x00000000eeffffff
> [    1.521579] PCI: Bridge: 0000:00:0b.0
> [    1.525226]   IO window: e000-efff
> [    1.528638]   MEM window: 0xefe00000-0xefefffff
> [    1.535226]   PREFETCH window: disabled.
> [    1.539295] PCI: Bridge: 0000:00:0c.0
> [    1.542960]   IO window: disabled.
> [    1.545226]   MEM window: 0xefd00000-0xefdfffff
> [    1.549763]   PREFETCH window: disabled.
> [    1.555227] PCI: Bridge: 0000:00:0d.0
> [    1.558897]   IO window: disabled.
> [    1.562304]   MEM window: 0xefc00000-0xefcfffff
> [    1.565226]   PREFETCH window: disabled.
> [    1.569159] PCI: Bridge: 0000:00:0f.0
> [    1.575226]   IO window: d000-dfff
> [    1.578632]   MEM window: 0xefb00000-0xefbfffff
> [    1.583162]   PREFETCH window: 0x00000000e0000000-0x00000000e7ffffff
> [    1.585317] NET: Registered protocol family 2
> [    1.695224] IP route cache hash table entries: 131072 (order: 8,
> 1048576 bytes)
> [    1.695224] TCP established hash table entries: 524288 (order: 11,
> 8388608 bytes)
> [    1.705988] TCP bind hash table entries: 65536 (order: 8, 1048576 bytes)
> [    1.713229] TCP: Hash tables configured (established 524288 bind 65536)

OK, so it looks like it died during networking initialisation.

Could you please add initcall_debug to the boot command line so we can see
which function it is getting stuck in?

