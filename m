From: Brice Goglin <brice@myri.com>
Subject: Re: [BUILD_FAILURE] 2.6.27-git2 - allyesconfig on
	powerpc selectsCONFIG_INTEL_IOATDMA=y
Date: Mon, 13 Oct 2008 20:21:45 +0200
Message-ID: <48F391B9.1000206@myri.com>
References: <20081013101559.GA14372@linux.vnet.ibm.com>
	<20081013112631.GD29938@cs181140183.pp.htv.fi>
	<36D9DB17C6DE9E40B059440DB8D95F52066E2EAE@orsmsx418.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Adrian Bunk <bunk@kernel.org>, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>,
	linuxppc-dev@ozlabs.org, "Kirsher,
	Jeffrey T" <jeffrey.t.kirsher@intel.com>, apw@shadowen.org,
	sam@ravnborg.org, Jeff Garzik <jgarzik@redhat.com>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <36D9DB17C6DE9E40B059440DB8D95F52066E2EAE@orsmsx418.amr.corp.intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Brandeburg, Jesse wrote:
> What we want, is myri10ge and ixgbe drivers that can build whether or not CONFIG_INTEL_IOATDMA is enabled.  IF CONFIG_INTEL_IOATDMA *is* enabled (which it should not be on PPC) then there are several cases we want to work:
> CONFIG_INTEL_IOATDMA=m  ---> CONFIG_IXGBE=[m|n]
> CONFIG_INTEL_IOATDMA=y  ---> CONFIG_IXGBE=[m|y|n]
> CONFIG_INTEL_IOATDMA=n  ---> CONFIG_IXGBE=[m|y|n]
> CONFIG_INTEL_IOATDMA depends on X86
>   

I am not sure I want to prevent myri10ge=y just because ioatdma=m.

I would vote for adding some Kconfig stuff to define CONFIG_MYRI10GE_DCA
as boolean set to yes if (IOATDMA=y and MYRI10GE=y/m) or (IOATDMA=m and
MYRI10GE=m). And then use #ifdef CONFIG_MYRI10GE_DCA in the driver source.

Brice


-------------------------------------------------------------------------
This SF.Net email is sponsored by the Moblin Your Move Developer's challenge
Build the coolest Linux based applications with Moblin SDK & win great prizes
Grand prize is a trip for two to an Open Source event anywhere in the world
http://moblin-contest.org/redirect.php?banner_id=100&url=/
