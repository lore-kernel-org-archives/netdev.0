From: Thomas Hellstrom <thellstrom@vmware.com>
Subject: Re: [Pv-drivers] [PATCH net v2] vmxnet3: segCnt can be 1 for LRO
 packets
Date: Wed, 8 Jun 2016 12:10:04 +0200
Message-ID: <5757EEFC.3060709@vmware.com>
References: <1465366415-124072-1-git-send-email-skhare@vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: Jin Heo <heoj@vmware.com>
To: Shrikrishna Khare <skhare@vmware.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <pv-drivers@vmware.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1465366415-124072-1-git-send-email-skhare@vmware.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/08/2016 08:13 AM, Shrikrishna Khare wrote:
> The device emulation may send segCnt of 1 for LRO packets.
>
> Signed-off-by: Shrikrishna Khare <skhare@vmware.com>
> Signed-off-by: Jin Heo <heoj@vmware.com>
>
> ---
> v2: fix subject line
> ---
>  drivers/net/vmxnet3/vmxnet3_drv.c | 2 +-
>  drivers/net/vmxnet3/vmxnet3_int.h | 4 ++--
>  2 files changed, 3 insertions(+), 3 deletions(-)
>
> diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
> index db8022a..6f399b2 100644
> --- a/drivers/net/vmxnet3/vmxnet3_drv.c
> +++ b/drivers/net/vmxnet3/vmxnet3_drv.c
> @@ -1369,7 +1369,7 @@ vmxnet3_rq_rx_complete(struct vmxnet3_rx_queue *rq,
>  				rcdlro = (struct Vmxnet3_RxCompDescExt *)rcd;
>  
>  				segCnt = rcdlro->segCnt;
> -				BUG_ON(segCnt <= 1);
> +				BUG_ON(segCnt == 0);

What will the vmxnet3 driver do otherwise if segCnt == 0? Please see below.


>  				mss = rcdlro->mss;
>  				if (unlikely(segCnt <= 1))
>  					segCnt = 0;

Based on this code, it looks like it can handle the case without taking
down the kernel completely, so instead of a
"BUG_ON", would it make sense with a WARN_ON_ONCE() or WARN_ON()?

Thanks,
Thomas
