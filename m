From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: powerpc allmodconfig
Date: Thu, 16 Oct 2008 15:56:50 +1100
Message-ID: <1224133010.8157.543.camel@pasglop>
References: <20081015213337.a99a9595.akpm@linux-foundation.org>
Reply-To: benh@kernel.crashing.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>, marek.vasut@gmail.com,
	Takashi Iwai <tiwai@suse.de>, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org,
	Ralf Baechle <ralf@linux-mips.org>,
	Mark Fasheh <mark.fasheh@oracle.com>, linuxppc-dev@ozlabs.org,
	linux-ide@vger.kernel.org, Dan Williams <dan.j.williams@intel.com>,
	linux-ext4@vger.kernel.org, David Woodhouse <dwmw2@infradead.org>,
	Mauro Carvalho Chehab <mchehab@infradead.org>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
In-Reply-To: <20081015213337.a99a9595.akpm@linux-foundation.org>
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

Some comments for some of these...

On Wed, 2008-10-15 at 21:33 -0700, Andrew Morton wrote:

> kernel/resource.c: In function '__reserve_region_with_split':
> kernel/resource.c:554: warning: format '%llx' expects type 'long long unsigned int', but argument 3 has type 'resource_size_t'
> kernel/resource.c:554: warning: format '%llx' expects type 'long long unsigned int', but argument 4 has type 'resource_size_t'
> kernel/resource.c:554: warning: format '%llx' expects type 'long long unsigned int', but argument 6 has type 'resource_size_t'
> kernel/resource.c:554: warning: format '%llx' expects type 'long long unsigned int', but argument 7 has type 'resource_size_t'

This is a generic code bug, I sent a patch for it a day or two ago. (ie
those are real bugs on 32-bit resource_size_t)

> drivers/dma/ioat_dca.c: In function 'dca_enabled_in_bios':
> drivers/dma/ioat_dca.c:81: error: implicit declaration of function 'cpuid_eax'
> drivers/dma/ioat_dca.c: In function 'system_has_dca_enabled':
> drivers/dma/ioat_dca.c:91: error: implicit declaration of function 'boot_cpu_has'
> drivers/dma/ioat_dca.c:91: error: 'X86_FEATURE_DCA' undeclared (first use in this function)
> drivers/dma/ioat_dca.c:91: error: (Each undeclared identifier is reported only once
> drivers/dma/ioat_dca.c:91: error: for each function it appears in.)
> drivers/dma/ioat_dca.c: In function 'ioat_dca_get_tag':
> drivers/dma/ioat_dca.c:190: error: implicit declaration of function 'cpu_physical_id'

Looks like this driver should depend on X86 :-)

> fs/ext4/balloc.c: In function 'ext4_claim_free_blocks':
> fs/ext4/balloc.c:607: warning: format '%lld' expects type 'long long int', but argument 2 has type 's64'
> fs/ext4/inode.c: In function 'ext4_print_free_blocks':
> fs/ext4/inode.c:1822: warning: format '%lld' expects type 'long long int', but argument 2 has type 's64'
> fs/ext4/inode.c:1824: warning: format '%lld' expects type 'long long int', but argument 2 has type 's64'

The above are unfortunate but at least aren't bugs per-se, just
annoying. Should be fixable with casts. Ted ?

> net/mac80211/rc80211_minstrel_debugfs.c: In function 'minstrel_stats_open':
> net/mac80211/rc80211_minstrel_debugfs.c:98: warning: format '%8llu' expects type 'long long unsigned int', but argument 11 has type 'u64'
> net/mac80211/rc80211_minstrel_debugfs.c:98: warning: format '%8llu' expects type 'long long unsigned int', but argument 12 has type 'u64'
> net/mac80211/rc80211_minstrel_debugfs.c:98: warning: format '%8llu' expects type 'long long unsigned int', but argument 11 has type 'u64'
> net/mac80211/rc80211_minstrel_debugfs.c:98: warning: format '%8llu' expects type 'long long unsigned int', but argument 12 has type 'u64'
> net/mac80211/rc80211_minstrel_debugfs.c: At top level:
> net/mac80211/rc80211_minstrel_debugfs.c:145: warning: initialization from incompatible pointer type

Same.

> fs/ocfs2/xattr.c: In function 'ocfs2_xattr_index_block_find':
> fs/ocfs2/xattr.c:2400: warning: format '%llu' expects type 'long long unsigned int', but argument 7 has type 'u64'
> fs/ocfs2/xattr.c:2400: warning: format '%llu' expects type 'long long unsigned int', but argument 7 has type 'u64'

 .../...

same

> 
> sound/pci/hda/patch_sigmatel.c: In function 'stac92xx_parse_auto_config':
> sound/pci/hda/patch_sigmatel.c:2819: warning: 'nid' may be used uninitialized in this function
> 
> drivers/rtc/rtc-ds1286.c: In function 'ds1286_rtc_read':
> drivers/rtc/rtc-ds1286.c:33: error: implicit declaration of function '__raw_readl'
> drivers/rtc/rtc-ds1286.c: In function 'ds1286_rtc_write':
> drivers/rtc/rtc-ds1286.c:38: error: implicit declaration of function '__raw_writel'
> drivers/rtc/rtc-ds1286.c: In function 'ds1286_probe':
> drivers/rtc/rtc-ds1286.c:345: error: implicit declaration of function 'ioremap'
> drivers/rtc/rtc-ds1286.c:345: warning: assignment makes pointer from integer without a cast
> drivers/rtc/rtc-ds1286.c:365: error: implicit declaration of function 'iounmap'
> make[2]: [drivers/rtc/rtc-ds1286.o] Error 1 (ignored)

Missing #include <asm/io.h> ?

> drivers/rtc/rtc-m48t35.c: In function 'm48t35_read_time':
> drivers/rtc/rtc-m48t35.c:59: error: implicit declaration of function 'readb'
> drivers/rtc/rtc-m48t35.c:60: error: implicit declaration of function 'writeb'
> drivers/rtc/rtc-m48t35.c: In function 'm48t35_probe':
> drivers/rtc/rtc-m48t35.c:168: error: implicit declaration of function 'ioremap'
> drivers/rtc/rtc-m48t35.c:168: warning: assignment makes pointer from integer without a cast
> drivers/rtc/rtc-m48t35.c:188: error: implicit declaration of function 'iounmap'

Same ?

> drivers/net/ibm_newemac/mal.c: In function 'mal_txeob':
> drivers/net/ibm_newemac/mal.c:284: error: implicit declaration of function 'mtdcri'
> drivers/net/ibm_newemac/mal.c:284: error: 'SDR0' undeclared (first use in this function)
> drivers/net/ibm_newemac/mal.c:284: error: (Each undeclared identifier is reported only once
> drivers/net/ibm_newemac/mal.c:284: error: for each function it appears in.)
> drivers/net/ibm_newemac/mal.c:285: error: implicit declaration of function 'mfdcri'
> drivers/net/ibm_newemac/mal.c: In function 'mal_rxeob':
> drivers/net/ibm_newemac/mal.c:302: error: 'SDR0' undeclared (first use in this function)

That's annoying, I'll have a look.

> drivers/net/wireless/libertas_tf/if_usb.c: In function '__if_usb_submit_rx_urb':
> drivers/net/wireless/libertas_tf/if_usb.c:334: warning: cast to pointer from integer of different size

Yuck !

I'll look at the EMAC one and maybe some more tomorrow if nobody beats
me to it.

Cheers,
Ben.
