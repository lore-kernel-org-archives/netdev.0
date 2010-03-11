From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/37] OF: move device node pointer into
	struct device.
Date: Thu, 11 Mar 2010 10:20:43 -0800 (PST)
Message-ID: <20100311.102043.40590962.davem@davemloft.net>
References: <20100311174830.4824.19820.stgit@angua>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: sfr@canb.auug.org.au, monstr@monstr.eu, broonie@opensource.wolfsonmicro.com,
	linux-scsi@vger.kernel.org, linux-ide@vger.kernel.org,
	benh@kernel.crashing.org, devicetree-discuss@lists.ozlabs.org,
	gregkh@suse.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, jeremy.kerr@canonical.com,
	linuxppc-dev@ozlabs.org, James.Bottomley@suse.de,
	linux-i2c@vger.kernel.org, ben-linux@fluff.org,
	microblaze-uclinux@itee.uq.edu.au, sparclinux@vger.kernel.org,
	akpm@linux-foundation.org, alsa-devel@alsa-project.org,
	jgarzik@pobox.com, dwmw2@infradead.org
To: grant.likely@secretlab.ca
Return-path: <alsa-devel-bounces@alsa-project.org>
In-Reply-To: <20100311174830.4824.19820.stgit@angua>
List-Unsubscribe: <http://mailman.alsa-project.org/mailman/listinfo/alsa-devel>,
	<mailto:alsa-devel-request@alsa-project.org?subject=unsubscribe>
List-Archive: <http://mailman.alsa-project.org/pipermail/alsa-devel>
List-Post: <mailto:alsa-devel@alsa-project.org>
List-Help: <mailto:alsa-devel-request@alsa-project.org?subject=help>
List-Subscribe: <http://mailman.alsa-project.org/mailman/listinfo/alsa-devel>,
	<mailto:alsa-devel-request@alsa-project.org?subject=subscribe>
Sender: alsa-devel-bounces@alsa-project.org
Errors-To: alsa-devel-bounces@alsa-project.org
List-Id: netdev.vger.kernel.org

From: Grant Likely <grant.likely@secretlab.ca>
Date: Thu, 11 Mar 2010 11:03:47 -0700

> Currently on OF enabled platforms, the device node pointer is stored in
> both device.archdata.of_node (.prom_node on sparc), and in of_device.node
> OF device tree support is being generalized to work on any platform, so
> instead of adding the of_node pointer to each platform's archdata
> individually, this patch series moves the of_node pointer into struct
> device proper and fixes up all users to reference the new location.
> 
> The last 3 patches in this series remove the old .archdata.of_node,
> .archdata.prom_node and of_device.node instances.
> 
> This series has been compile tested on powerpc, sparc and microblaze,
> (allmodconfig used on sparc and powerpc) and boot tested on an mpc5200
> powerpc.  All known (or at least all I could find) in-tree users of the
> old names have been removed.

Three or four of the patches don't apply because only your tree
has those "/* temporary */" comments, f.e. in arch/sparc/kernel/pci.c

I took care of this when applying to my tree.

> This series should also be fully bisectable.  After I collect acks, I
> would like to get this whole series into linux-next to see if I've
> missed any references, but I can probably hold off merging the last
> three patches when the 2.6.35 merge window opens to give out of tree
> users a bit more time to adapt.  In fact, I'd probably wait a few
> extra days after pushing out the bulk of this series before I push the
> last 3 patches into my linux-next branch to isolate the drivers that I
> missed while fixing.

I'd rather you just apply the sparc one immediately in 2.6.35 and
not wait at all.
