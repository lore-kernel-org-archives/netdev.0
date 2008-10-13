From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: Re: [BUILD_FAILURE] 2.6.27-git2 - allyesconfig on
	powerpc selectsCONFIG_INTEL_IOATDMA=y
Date: Mon, 13 Oct 2008 11:05:43 -0700
Message-ID: <36D9DB17C6DE9E40B059440DB8D95F52066E2EAE@orsmsx418.amr.corp.intel.com>
References: <20081013101559.GA14372@linux.vnet.ibm.com>
	<20081013112631.GD29938@cs181140183.pp.htv.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org,
	apw@shadowen.org, sam@ravnborg.org
To: "Adrian Bunk" <bunk@kernel.org>,
	"Kamalesh Babulal" <kamalesh@linux.vnet.ibm.com>,
	"Brice Goglin" <brice@myri.com>, "Jeff Garzik" <jgarzik@redhat.com>,
	"Kirsher, Jeffrey T" <jeffrey.t
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-class: urn:content-classes:message
In-Reply-To: <20081013112631.GD29938@cs181140183.pp.htv.fi>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Adrian Bunk wrote:
> On Mon, Oct 13, 2008 at 03:45:59PM +0530, Kamalesh Babulal wrote:
>> Hi,
>> =

>>    2.6.27-git2 kernel build fails, while building the kernel with

from subject, on PPC.

>> allyesconfig option. The allyesconfig selects CONFIG_INTEL_IOATDMA=3Dy
>> =

>> CC   drivers/dma/ioat_dca.o
>> drivers/dma/ioat_dca.c: In function =E2=80=98dca_enabled_in_bios=E2=80=
=99:
>> drivers/dma/ioat_dca.c:81: error: implicit declaration of function
>> =E2=80=98cpuid_eax=E2=80=99 drivers/dma/ioat_dca.c: In function
>> =E2=80=98system_has_dca_enabled=E2=80=99: =

>> drivers/dma/ioat_dca.c:91: error: implicit declaration of function
>> =E2=80=98boot_cpu_has=E2=80=99 drivers/dma/ioat_dca.c:91: error:
>> =E2=80=98X86_FEATURE_DCA=E2=80=99 undeclared (first use in this function)
>> drivers/dma/ioat_dca.c:91: error: (Each undeclared identifier is
>> reported only once drivers/dma/ioat_dca.c:91: error: for each
>> function it appears in.)  =

>> drivers/dma/ioat_dca.c: In function =E2=80=98ioat_dca_get_tag=E2=80=99:
>> drivers/dma/ioat_dca.c:190: error: implicit declaration of function
>> =E2=80=98cpu_physical_id=E2=80=99 make[2]: *** [drivers/dma/ioat_dca.o] =
Error 1
>> make[1]: *** [drivers/dma] Error 2
>> make: *** [drivers] Error 2
>> ...
> =

> Thanks for the report, the MYRI10GE and IXGBE commits that introduced
> the select's are really broken.

it fixed an obvious bug with CONFIG_IXGBE=3Dy and CONFIG_INTEL_IOATDMA=3Dm,=
 unfortunate that it is so difficult to use Kconfig for the uninitiated.
 =

> For fixing it I need to know the intended semantics.
> =

> Brian, Jesse, is it OK to limit the drivers to m with
> CONFIG_INTEL_IOATDMA=3Dm ?

why is the IOATDMA driver not depending on x86?  x86 hardware (32 and 64 bi=
t) are the only machines that will have ioatdma support, since the ioatdma =
(and dca) device is only in Intel server chipsets since S5000 (aka S5000, S=
5400, S7400 and derivatives/followons)

What we want, is myri10ge and ixgbe drivers that can build whether or not C=
ONFIG_INTEL_IOATDMA is enabled.  IF CONFIG_INTEL_IOATDMA *is* enabled (whic=
h it should not be on PPC) then there are several cases we want to work:
CONFIG_INTEL_IOATDMA=3Dm  ---> CONFIG_IXGBE=3D[m|n]
CONFIG_INTEL_IOATDMA=3Dy  ---> CONFIG_IXGBE=3D[m|y|n]
CONFIG_INTEL_IOATDMA=3Dn  ---> CONFIG_IXGBE=3D[m|y|n]
CONFIG_INTEL_IOATDMA depends on X86

same for myri10ge I think.  I hope that cleared something up, we can seriou=
sly use some help from the experts to get Kconfig correct for this.

-------------------------------------------------------------------------
This SF.Net email is sponsored by the Moblin Your Move Developer's challenge
Build the coolest Linux based applications with Moblin SDK & win great priz=
es
Grand prize is a trip for two to an Open Source event anywhere in the world
http://moblin-contest.org/redirect.php?banner_id=3D100&url=3D/
