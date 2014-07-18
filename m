From: James Bottomley <James.Bottomley@HansenPartnership.com>
Subject: Re: [PATCH 0/25] Replace DEFINE_PCI_DEVICE_TABLE macro use
Date: Fri, 18 Jul 2014 09:54:32 -0700
Message-ID: <1405702472.30262.1.camel@dabdike.int.hansenpartnership.com>
References: <1405697232-11785-1-git-send-email-benoit.taine@lip6.fr>
 <20140718162213.GC31114@tuxdriver.com> <20140718164340.GA24960@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-mips@linux-mips.org, linux-fbdev@vger.kernel.org,
 linux-pci@vger.kernel.org, dri-devel@lists.freedesktop.org,
 virtualization@lists.linux-foundation.org, Benoit Taine <benoit.taine@lip6.fr>,
 ath5k-devel@venema.h4ckr.net, linux-acenic@sunsite.dk,
 linux-scsi@vger.kernel.org, users@rt2x00.serialmonkey.com,
 linux-rdma@vger.kernel.org, ath10k@lists.infradead.org, linux-hippi@sunsite.dk,
 industrypack-devel@lists.sourceforge.net, linux-wireless@vger.kernel.org,
 xen-devel@lists.xenproject.org, MPT-FusionLinux.pdl@avagotech.com,
 ath9k-devel@venema.h4ckr.net, wil6210@qca.qualcomm.com,
 linux-pcmcia@lists.infradead.org, "John W. Linville" <linville@tuxdriver.com>,
 linux-can@vger.kernel.org, platform-driver-x86@vger.kernel.org,
 netdev@vger.kernel.org, linux-mmc@vger.kernel.org,
 linux-kernel@vger.kernel.org, e1000-devel@lists.sourceforge.net,
 linux-crypto@vger.kernel.org, devel@l
To: Greg KH <greg@kroah.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20140718164340.GA24960@kroah.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

On Fri, 2014-07-18 at 09:43 -0700, Greg KH wrote:
> On Fri, Jul 18, 2014 at 12:22:13PM -0400, John W. Linville wrote:
> > On Fri, Jul 18, 2014 at 05:26:47PM +0200, Benoit Taine wrote:
> > > We should prefer `const struct pci_device_id` over
> > > `DEFINE_PCI_DEVICE_TABLE` to meet kernel coding style guidelines.
> > > This issue was reported by checkpatch.
> > 
> > Honestly, I prefer the macro -- it stands-out more.  Maybe the style
> > guidelines and/or checkpatch should change instead?
> 
> The macro is horrid, no other bus has this type of thing just to save a
> few characters in typing

OK, so this is the macro:

#define DEFINE_PCI_DEVICE_TABLE(_table) \
	const struct pci_device_id _table[]

Could you explain what's so horrible?

The reason it's useful today is that people forget the const (and
sometimes the [] making it a true table instead of a pointer).  If you
use the DEFINE_PCI_DEVICE_TABLE macro, the compile breaks if you use it
wrongly (good) and you automatically get the correct annotations.

> , so why should PCI be "special" in this regard
> anymore?

I think the PCI usage dwarfs most other bus types now, so you could turn
the question around.  However, I don't think majority voting is a good
guide to best practise; lets debate the merits for their own sake.

James
