From: Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH] net: wireless: iwlwifi: remove minor dead code
Date: Sun, 10 Nov 2013 23:15:28 +0400
Message-ID: <527FDB50.1050902@cogentembedded.com>
References: <1384110397-24386-1-git-send-email-mpn@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Intel Linux Wireless <ilw-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Michal Nazarewicz <mina86-deATy8a+UHjQT0dZR+AlfA@public.gmane.org>
To: Michal Nazarewicz <mpn-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Emmanuel Grumbach <emmanuel.grumbach-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1384110397-24386-1-git-send-email-mpn-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello.

On 10-11-2013 23:06, Michal Nazarewicz wrote:

> From: Michal Nazarewicz <mina86-deATy8a+UHjQT0dZR+AlfA@public.gmane.org>

> inta is checked to be zero in a IRQ_NONE branch so afterwards it
> cannot be zero as it is never modified.

> Signed-off-by: Michal Nazarewicz <mina86-deATy8a+UHjQT0dZR+AlfA@public.gmane.org>
> ---
>   drivers/net/wireless/iwlwifi/pcie/rx.c | 23 ++++++++---------------
>   1 file changed, 8 insertions(+), 15 deletions(-)

> diff --git a/drivers/net/wireless/iwlwifi/pcie/rx.c b/drivers/net/wireless/iwlwifi/pcie/rx.c
> index 3f237b4..c32122a 100644
> --- a/drivers/net/wireless/iwlwifi/pcie/rx.c
> +++ b/drivers/net/wireless/iwlwifi/pcie/rx.c
[...]
> @@ -1150,7 +1149,13 @@ static irqreturn_t iwl_pcie_isr(int irq, void *data)
>   	 * or due to sporadic interrupts thrown from our NIC. */
>   	if (!inta) {
>   		IWL_DEBUG_ISR(trans, "Ignore interrupt, inta == 0\n");
> -		goto none;
> +		/* re-enable interrupts here since we don't have anything to
> +		 * service.  only Re-enable if disabled by irq and no
> +		 * schedules tasklet. */

    The preferred way of formatting the multi-line comments in the networking 
code is this:

/* bla
  * bla
  */

WBR, Sergei

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
