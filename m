From: Brice Goglin <brice@myri.com>
Subject: Re: powerpc allmodconfig
Date: Thu, 16 Oct 2008 08:55:08 +0200
Message-ID: <48F6E54C.5010207@myri.com>
References: <20081015213337.a99a9595.akpm@linux-foundation.org>	
	<20081015.220247.262683261.davem@davemloft.net>
	<1224137292.26782.5.camel@dwillia2-linux.ch.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: bzolnier@gmail.com, marek.vasut@gmail.com, tiwai@suse.de,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	linux-kernel@vger.kernel.org, ralf@linux-mips.org,
	mark.fasheh@oracle.com, linuxppc-dev@ozlabs.org,
	linux-ide@vger.kernel.org, jesse.brandeburg@intel.com,
	akpm@linux-foundation.org, linux-ext4@vger.kernel.org,
	dwmw2@infradead.org, David Miller <davem@davemloft.net>,
	mchehab@infradead.org
To: Dan Williams <dan.j.williams@intel.com>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
In-Reply-To: <1224137292.26782.5.camel@dwillia2-linux.ch.intel.com>
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

Dan Williams wrote:
> On Wed, 2008-10-15 at 22:02 -0700, David Miller wrote:
>   
>>> drivers/dma/ioat_dca.c: In function 'dca_enabled_in_bios':
>>> drivers/dma/ioat_dca.c:81: error: implicit declaration of function 'cpuid_eax'
>>> drivers/dma/ioat_dca.c: In function 'system_has_dca_enabled':
>>> drivers/dma/ioat_dca.c:91: error: implicit declaration of function 'boot_cpu_has'
>>> drivers/dma/ioat_dca.c:91: error: 'X86_FEATURE_DCA' undeclared (first use in this function)
>>> drivers/dma/ioat_dca.c:91: error: (Each undeclared identifier is reported only once
>>> drivers/dma/ioat_dca.c:91: error: for each function it appears in.)
>>> drivers/dma/ioat_dca.c: In function 'ioat_dca_get_tag':
>>> drivers/dma/ioat_dca.c:190: error: implicit declaration of function 'cpu_physical_id'
>>>       
>> Known issue.  I tried to ping Jeff Garzik about doing a driver bug fix run in
>> order to fix this, but he hasn't shown any signs of life.
>>
>> So I'll do it myself later tonight. :-/
>>
>>     
> The following seems to fix this up...
>
> ---snip--->
> ixgbe, myri10ge: INTEL_IOATDMA can only be selected when X86=y
>   

There's already a completely different fix queued in netdev patchworks
(for myri10ge only right now, to be duplicated for Intel drivers). The
idea is to stop having almost-unrelated drivers select each other
directly, let people select which drivers they really want, and have
Kconfig handle modules/builtin-stuff correctly. See
http://patchwork.ozlabs.org/patch/4506/

Brice
