From: "David S. Miller" <davem@redhat.com>
Subject: Re: Fw: Badness in local_bh_enable at kernel/softirq.c:119
Date: Wed, 1 Oct 2003 01:37:10 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031001013710.425038fd.davem@redhat.com>
References: <C6F5CF431189FA4CBAEC9E7DD5441E010124F0B1@orsmsx402.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, akpm@osdl.org, netdev@oss.sgi.com, cramerj@intel.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Feldman, Scott" <scott.feldman@intel.com>
In-Reply-To: <C6F5CF431189FA4CBAEC9E7DD5441E010124F0B1@orsmsx402.jf.intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 1 Oct 2003 01:19:41 -0700
"Feldman, Scott" <scott.feldman@intel.com> wrote:

> Synchronizing on the hardware side is stumping me.  We have the list of
> skbs you describe, but I'm concerned about unmapping the skb buffers if
> hardware is right in the middle of some DMA  on one of the buffers.
> Some archs really don't like hardware accessing unmapped buffers.

Good point, if the e1000 accesses the DMA buffer after the unmap
it will cause many arch's to signal PCI errors since the IOMMU
will no longer have a valid translation for those DMA requests.

> Here's what I'm thinking: when link down is detected in the timer, just
> trick hardware into thinking link is still up (ILOS - Invert Loss of
> Signal).  No locking, no disabling of interrupts.  Hardware will do the
> natural thing by completing the outstanding sends and also provide the
> interrupts so we can clean/return skbs as normal (e1000_clean_tx_irq).

If you can make that work, it's the simplest fix.
