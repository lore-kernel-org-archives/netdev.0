From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] VMXNET3: Check for map error in vmxnet3_set_mc
Date: Wed, 03 Sep 2014 00:02:35 +0400
Message-ID: <5406225B.305@cogentembedded.com>
References: <1409675408-8440-1-git-send-email-acking@vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: pv-drivers@vmware.com, penguin-kernel@I-love.SAKURA.ne.jp,
	davem@davemloft.net
To: Andy King <acking@vmware.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1409675408-8440-1-git-send-email-acking@vmware.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

Hello.

On 09/02/2014 08:30 PM, Andy King wrote:

> We should check if the map of the table actually succeeds, and also free
> resources accordingly. This fixes the kernel panic reported by Tetsuo
> Handa.

    There's "Reported-by:" line for that.

> Version bumped to 1.2.1.0

> Acked-by: Shelley Gong <shelleygong@vmware.com>
> Acked-by: Bhavesh Davda <bhavesh@vmware.com>
> Signed-off-by: Andy King <acking@vmware.com>
> ---
>   drivers/net/vmxnet3/vmxnet3_drv.c |   14 ++++++++------
>   drivers/net/vmxnet3/vmxnet3_int.h |    4 ++--
>   2 files changed, 10 insertions(+), 8 deletions(-)

> diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
> index d6e90c7..f450010 100644
> --- a/drivers/net/vmxnet3/vmxnet3_drv.c
> +++ b/drivers/net/vmxnet3/vmxnet3_drv.c
[...]
> @@ -2091,11 +2093,11 @@ vmxnet3_set_mc(struct net_device *netdev)
>   			       VMXNET3_CMD_UPDATE_MAC_FILTERS);
>   	spin_unlock_irqrestore(&adapter->cmd_lock, flags);
>
> -	if (new_table) {
> +	if (new_table_pa)
>   		dma_unmap_single(&adapter->pdev->dev, new_table_pa,
>   				 rxConf->mfTableLen, PCI_DMA_TODEVICE);
> +	if (new_table)
>   		kfree(new_table);

    The above *if* is not needed -- kfree() already checks for NULL.

[...]

WBR, Sergei
