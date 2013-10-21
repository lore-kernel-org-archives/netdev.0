From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next v3 02/07] r8169: Support for byte queue limits
Date: Mon, 21 Oct 2013 17:38:00 +0400
Message-ID: <52652E38.5020207@cogentembedded.com>
References: <1382296991-20289-1-git-send-email-milky-kernel@mcmilk.de> <1382296991-20289-3-git-send-email-milky-kernel@mcmilk.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Tino Reichardt <milky-kernel@mcmilk.de>, netdev@vger.kernel.org,
	Realtek linux nic maintainers <nic_swsd@realtek.com>,
	Igor Maravic <igorm@etf.rs>,
	Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f52.google.com ([209.85.215.52]:42210 "EHLO
	mail-la0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753253Ab3JUNiD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Oct 2013 09:38:03 -0400
Received: by mail-la0-f52.google.com with SMTP id eh20so550897lab.11
        for <netdev@vger.kernel.org>; Mon, 21 Oct 2013 06:38:02 -0700 (PDT)
In-Reply-To: <1382296991-20289-3-git-send-email-milky-kernel@mcmilk.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 10/20/2013 11:23 PM, Tino Reichardt wrote:

> Changes to r8169 driver to use byte queue limits.


> Signed-off-by: Tino Reichardt <milky-kernel@mcmilk.de>

> ---
>   drivers/net/ethernet/realtek/r8169.c | 14 ++++++++++++++
>   1 file changed, 14 insertions(+)

> diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
> index 3397cee..8f12145 100644
> --- a/drivers/net/ethernet/realtek/r8169.c
> +++ b/drivers/net/ethernet/realtek/r8169.c
[...]
> @@ -818,6 +819,9 @@ MODULE_AUTHOR("Realtek and the Linux r8169 crew <netdev@vger.kernel.org>");
>   MODULE_DESCRIPTION("RealTek RTL-8169 Gigabit Ethernet driver");
>   module_param(use_dac, int, 0);
>   MODULE_PARM_DESC(use_dac, "Enable PCI DAC. Unsafe on 32 bit PCI slot.");
> +module_param(bql_disable, bool, 0);
> +MODULE_PARM_DESC(bql_disable,
> +	"Disable Byte Queue Limits functionality (default: false)");
>   module_param_named(debug, debug.msg_enable, int, 0);
>   MODULE_PARM_DESC(debug, "Debug verbosity level (0=none, ..., 16=all)");
>   MODULE_LICENSE("GPL");
> @@ -5841,6 +5845,8 @@ static void rtl8169_tx_clear(struct rtl8169_private *tp)
>   {
>   	rtl8169_tx_clear_range(tp, tp->dirty_tx, NUM_TX_DESC);
>   	tp->cur_tx = tp->dirty_tx = 0;
> +	if (unlikely(bql_disable))
> +		netdev_reset_queue(tp->dev);

    Joe has inverted the logic in his request and you blindly followed it. He 
must have meant !bql_disable. Also, unlikely() does not really fit here, so in 
fact Joe's request was completely invalid.

WBR, Sergei
