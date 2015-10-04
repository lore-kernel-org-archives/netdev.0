From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH net-next] net/mlx4_core: Test interrupts fail if not all
 comp vectors called request_irq
Date: Sun, 4 Oct 2015 11:03:18 +0300
Message-ID: <5610DD46.204@mellanox.com>
References: <1443551891-17971-1-git-send-email-clsoto@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <brking@linux.vnet.ibm.com>,
	<amirv@mellanox.com>
To: <clsoto@linux.vnet.ibm.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db3on0091.outbound.protection.outlook.com ([157.55.234.91]:29440
	"EHLO emea01-db3-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751072AbbJDITK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 4 Oct 2015 04:19:10 -0400
In-Reply-To: <1443551891-17971-1-git-send-email-clsoto@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/29/2015 9:38 PM, clsoto@linux.vnet.ibm.com wrote:
> From: Carol L Soto <clsoto@linux.vnet.ibm.com>
>
> Test interrupts fails if not all completion vectors called
> request_irq. This case can happen if only mlx4_en loads and
> we have more completion vectors than rx rings.

good catch! is this a bug since the driver 0-day or was introduced by
some recent commit? in the latercase, please add a Fixes: tag before 
your S.O.B note.
>
> Signed-off-by: Carol L Soto <clsoto@linux.vnet.ibm.com>
> ---
>   drivers/net/ethernet/mellanox/mlx4/eq.c | 4 ++++
>   1 file changed, 4 insertions(+)
>
> diff --git a/drivers/net/ethernet/mellanox/mlx4/eq.c b/drivers/net/ethernet/mellanox/mlx4/eq.c
> index 8e81e53..c344884 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/eq.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/eq.c
> @@ -1364,6 +1364,10 @@ int mlx4_test_interrupts(struct mlx4_dev *dev)
>   	 * and performing a NOP command
>   	 */
>   	for(i = 0; !err && (i < dev->caps.num_comp_vectors); ++i) {
> +		/* Make sure request_irq was called */
> +		if (!priv->eq_table.eq[i].have_irq)
> +			continue;
> +
>   		/* Temporary use polling for command completions */
>   		mlx4_cmd_use_polling(dev);
>   
