From: Laurent Chavey <chavey@google.com>
Subject: Re: e100 REGRESSION in 2.6.32 (PATCH v2)
Date: Thu, 17 Dec 2009 13:15:04 -0800
Message-ID: <97949e3e0912171315g537903f7m9461ea8399dc018c@mail.gmail.com>
References: <Pine.LNX.4.44L0.0912171046070.2645-100000@iolanthe.rowland.org>
	<200912171810.45575.roger.oksanen@cs.helsinki.fi>
	<alpine.WNT.2.00.0912170919010.2612@jbrandeb-desk1.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>, "Allan,
	Bruce W" <bruce.w.allan@intel.com>,
	Kernel development list <linux-kernel@vger.kernel.org>, "Ronciak,
	John" <john.ronciak@intel.com>,
	Alan Stern <stern@rowland.harvard.edu>, "Kirsher,
	Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	Roger Oksanen <roger.oksanen@cs.helsinki.fi>,
	David Miller <davem@davemloft.net>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <alpine.WNT.2.00.0912170919010.2612@jbrandeb-desk1.amr.corp.intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

when using DMAPOOL_DEBUG, do we really want to
over-write 	memset(retval, POOL_POISON_ALLOCATED, pool->size);
set in  dma_pool_alloc.


On Thu, Dec 17, 2009 at 9:21 AM, Brandeburg, Jesse
<jesse.brandeburg@intel.com> wrote:
>
> On Thu, 17 Dec 2009, Roger Oksanen wrote:
>> e100: Fix broken cbs accounting due to missing memset.
>>
>> Alan Stern noticed that e100 caused slab corruption.
>> commit 98468efddb101f8a29af974101c17ba513b07be1 changed
>> the allocation of cbs to use dma pools that don't return zeroed memory,
>> especially the cb->status field used to track which cb to clean, causing
>> (the visible) double freeing of skbs and a wrong free cbs count.
>>
>> Now the cbs are explicitly zeroed at allocation time.
>>
>> Reported-by: Alan Stern <stern@rowland.harvard.edu>
>> Tested-by: Alan Stern <stern@rowland.harvard.edu>
>> Signed-off-by: Roger Oksanen <roger.oksanen@cs.helsinki.fi>
>
> Change looks reasonable, ACK.
>
> should we also consider a followon patch to zero memory allocated with
> pci_pools? =A0Seems useful.
>
> Acked-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>

---------------------------------------------------------------------------=
---
This SF.Net email is sponsored by the Verizon Developer Community
Take advantage of Verizon's best-in-class app development support
A streamlined, 14 day to market process makes app distribution fast and easy
Join now and get one step closer to millions of Verizon customers
http://p.sf.net/sfu/verizon-dev2dev =
