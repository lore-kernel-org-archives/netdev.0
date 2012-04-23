From: Dan Williams <dan.j.williams@intel.com>
Subject: Re: [PATCH v1 6/8] dmaengine: enhance network subsystem to support
 DMA device hotplug
Date: Mon, 23 Apr 2012 11:30:33 -0700
Message-ID: <CABE8wwvi_Yz8AyALr1-uDW9xSgrSqfrYWhB_22NQ2ydTa81+mg@mail.gmail.com>
References: <1335189109-4871-1-git-send-email-jiang.liu@huawei.com>
	<1335189109-4871-7-git-send-email-jiang.liu@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Vinod Koul <vinod.koul@intel.com>,
	Jiang Liu <jiang.liu@huawei.com>,
	Keping Chen <chenkeping@huawei.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	linux-pci@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jiang Liu <liuj97@gmail.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <1335189109-4871-7-git-send-email-jiang.liu@huawei.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 23, 2012 at 6:51 AM, Jiang Liu <liuj97@gmail.com> wrote:
> Enhance network subsystem to correctly update DMA channel reference counts,
> so it won't break DMA device hotplug logic.
>
> Signed-off-by: Jiang Liu <liuj97@gmail.com>

This introduces an atomic action on every channel touch, which is more
expensive than what we had previously.  There has always been a
concern about the overhead of offload that sometimes makes ineffective
or a loss compared to cpu copies.  In the cases where net_dma shows
improvement this will eat into / maybe eliminate that advantage.

Take a look at where dmaengine started [1].  It was from the beginning
going through contortions to avoid something like this.  We made it
simpler here [2], but still kept the principle of not dirtying a
shared cacheline on every channel touch, and certainly not locking it.

If you are going to hotplug the entire IOH, then you are probably ok
with network links going down, so could you just down the links and
remove the driver with the existing code?

--
Dan

[1]: http://git.kernel.org/?p=linux/kernel/git/torvalds/linux.git;a=commitdiff;h=c13c826
[2]: http://git.kernel.org/?p=linux/kernel/git/torvalds/linux.git;a=commitdiff;h=6f49a57a
