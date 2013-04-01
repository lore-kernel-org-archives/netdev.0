From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next 7/7] r8169: fix could not dump registers
Date: Mon, 01 Apr 2013 18:07:16 +0400
Message-ID: <51599494.3020307@cogentembedded.com>
References: <1364824539-4156-1-git-send-email-hayeswang@realtek.com> <1364824539-4156-7-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Hayes Wang <hayeswang@realtek.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1364824539-4156-7-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 01-04-2013 17:55, Hayes Wang wrote:

> For new version of Fedora and Ubuntu, we see all 0xff when dumping
> the hw regs through ethtool. Using a loop to read registers could
> fix it.

> Signed-off-by: Hayes Wang <hayeswang@realtek.com>
> ---
>   drivers/net/ethernet/realtek/r8169.c | 6 +++++-
>   1 file changed, 5 insertions(+), 1 deletion(-)

> diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
> index 876e088..c9cd64c 100644
> --- a/drivers/net/ethernet/realtek/r8169.c
> +++ b/drivers/net/ethernet/realtek/r8169.c
> @@ -1889,12 +1889,16 @@ static void rtl8169_get_regs(struct net_device *dev, struct ethtool_regs *regs,
>   			     void *p)
>   {
>   	struct rtl8169_private *tp = netdev_priv(dev);
> +	void __iomem *ioaddr = tp->mmio_addr;
> +	u8 *d = (u8 *)p;

    Casts from 'void *' are automatic, so no need for explicit one.

WBR, Sergei
