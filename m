From: =?ISO-8859-1?Q?Anders_Grafstr=F6m?= <grfstrm@users.sourceforge.net>
Subject: Re: Validation of DMA params breaks e100 driver (2.6.28-rc2)
Date: Fri, 14 Nov 2008 21:37:33 +0100
Message-ID: <491DE18D.2070302@users.sourceforge.net>
References: <4909E08F.9040306@users.sourceforge.net>
	<20081031210131.GA18015@flint.arm.linux.org.uk>
	<Pine.WNT.4.63.0811131718390.984@jbrandeb-desk.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: Russell King - ARM Linux <linux@arm.linux.org.uk>,
	"linux-arm-kernel@lists.arm.linux.org.uk"
	<linux-arm-kernel@lists.arm.linux.org.uk>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	e1000-devel@lists.sourceforge.net
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.arm.linux.org.uk>
In-Reply-To: <Pine.WNT.4.63.0811131718390.984@jbrandeb-desk.amr.corp.intel.com>
List-Unsubscribe: <http://lists.arm.linux.org.uk/mailman/listinfo/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.arm.linux.org.uk?subject=unsubscribe>
List-Archive: <http://lists.arm.linux.org.uk/lurker/list/linux-arm-kernel.html>
List-Post: <mailto:linux-arm-kernel@lists.arm.linux.org.uk>
List-Help: <mailto:linux-arm-kernel-request@lists.arm.linux.org.uk?subject=help>
List-Subscribe: <http://lists.arm.linux.org.uk/mailman/listinfo/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.arm.linux.org.uk?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.arm.linux.org.uk
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org+linux-arm-kernel=m.gmane.org@lists.arm.linux.org.uk
List-Id: netdev.vger.kernel.org

Brandeburg, Jesse wrote:
> On Fri, 31 Oct 2008, Russell King - ARM Linux wrote:
> =

>> On Thu, Oct 30, 2008 at 05:27:59PM +0100, Anders Grafstr=F6m wrote:
>>> The e100 driver triggers BUG_ON(buf->direction !=3D dir)
>>> by doing pci_map_single(..., PCI_DMA_BIDIRECTIONAL)
>>> and pci_dma_sync_single_for_device(..., PCI_DMA_TODEVICE).
>>>
>>> I'm guessing it's allowed to do that and that something like
>>> the patch below is called for?
>> No, it is not allowed to do that - that's why it's called "BUG_ON".
>> Changing the DMA direction, especially with dmabounce will result
>> in unexpected behaviour.
> =

> okay, how about this patch...  only compile tested as I couldn't get =

> net-next-2.6 to boot on my test machine.  I'll get some testing done on =

> this, but in the meantime....
> =

> e100: fix dma error in direction for mapping
> =

> From: Jesse Brandeburg <jesse.brandeburg@intel.com>

I failed to save this patch (flowed format?) but I applied it manually
to 2.6.28-rc4 and tried it. Appears to work.


-------------------------------------------------------------------
List admin: http://lists.arm.linux.org.uk/mailman/listinfo/linux-arm-kernel
FAQ:        http://www.arm.linux.org.uk/mailinglists/faq.php
Etiquette:  http://www.arm.linux.org.uk/mailinglists/etiquette.php
