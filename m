From: Brice Goglin <brice@myri.com>
Subject: Re: [BUILD_FAILURE] 2.6.27-git2 - allyesconfig on powerpc selects
 CONFIG_INTEL_IOATDMA=y
Date: Mon, 13 Oct 2008 14:02:26 +0200
Message-ID: <48F338D2.9080300@myri.com>
References: <20081013101559.GA14372@linux.vnet.ibm.com> <20081013112631.GD29938@cs181140183.pp.htv.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>,
	Jeff Garzik <jgarzik@redhat.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	linux-kernel@vger.kernel.org, apw@shadowen.org,
	linuxppc-dev@ozlabs.org, sam@ravnborg.org,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Adrian Bunk <bunk@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1873 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755785AbYJMMCW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Oct 2008 08:02:22 -0400
In-Reply-To: <20081013112631.GD29938@cs181140183.pp.htv.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adrian Bunk wrote:
> On Mon, Oct 13, 2008 at 03:45:59PM +0530, Kamalesh Babulal wrote:
>  =20
>> Hi,
>>
>>    2.6.27-git2 kernel build fails, while building the kernel with
>> allyesconfig option. The allyesconfig selects CONFIG_INTEL_IOATDMA=3D=
y
>>
>> CC   drivers/dma/ioat_dca.o
>> drivers/dma/ioat_dca.c: In function =C3=A2=C2=80=C2=98dca_enabled_in=
_bios=C3=A2=C2=80=C2=99:
>> drivers/dma/ioat_dca.c:81: error: implicit declaration of function =C3=
=A2=C2=80=C2=98cpuid_eax=C3=A2=C2=80=C2=99
>> drivers/dma/ioat_dca.c: In function =C3=A2=C2=80=C2=98system_has_dca=
_enabled=C3=A2=C2=80=C2=99:
>> drivers/dma/ioat_dca.c:91: error: implicit declaration of function =C3=
=A2=C2=80=C2=98boot_cpu_has=C3=A2=C2=80=C2=99
>> drivers/dma/ioat_dca.c:91: error: =C3=A2=C2=80=C2=98X86_FEATURE_DCA=C3=
=A2=C2=80=C2=99 undeclared (first use in this function)
>> drivers/dma/ioat_dca.c:91: error: (Each undeclared identifier is rep=
orted only once
>> drivers/dma/ioat_dca.c:91: error: for each function it appears in.)
>> drivers/dma/ioat_dca.c: In function =C3=A2=C2=80=C2=98ioat_dca_get_t=
ag=C3=A2=C2=80=C2=99:
>> drivers/dma/ioat_dca.c:190: error: implicit declaration of function =
=C3=A2=C2=80=C2=98cpu_physical_id=C3=A2=C2=80=C2=99
>> make[2]: *** [drivers/dma/ioat_dca.o] Error 1
>> make[1]: *** [drivers/dma] Error 2
>> make: *** [drivers] Error 2
>> ...
>>    =20
>
> Thanks for the report, the MYRI10GE and IXGBE commits that introduced=
=20
> the select's are really broken.
>
> For fixing it I need to know the intended semantics.
>
> Brian, Jesse, is it OK to limit the drivers to m with=20
> CONFIG_INTEL_IOATDMA=3Dm ?
>  =20

I think I would rather drop DCA from myri10ge if IOATDMA=3Dm while
myri10ge=3Dy. What's the simplest way to do so?

When Jesse told me to commit this in myri10ge, I thought it would be
nice to have DCA work the same than NETDMA/DMAengine does: you can have
NETDMA enabled without IOATDMA (either not built at all, or just not
loaded). You just don't get any DMA channel when you ask for one. Why
not do the same for DCA? There could be some generic DCA layer that can
be built all the time and returns DCA resources only if IOATDMA is
loaded/built ?

Brice

