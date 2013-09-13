From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 1/1] isdn: hfcpci_softirq: get func return to suppress
 compiler warning
Date: Fri, 13 Sep 2013 22:07:40 +0100
Message-ID: <1379106460.2438.16.camel@bwh-desktop.uk.level5networks.com>
References: <1379094259-6237-1-git-send-email-antonio.alecrim@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Karsten Keil <isdn@linux-pingi.de>,
	Masanari Iida <standby24x7@gmail.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: Antonio Alecrim Jr <antonio.alecrim@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1379094259-6237-1-git-send-email-antonio.alecrim@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2013-09-13 at 14:44 -0300, Antonio Alecrim Jr wrote:
> Signed-off-by: Antonio Alecrim Jr <antonio.alecrim@gmail.com>
> ---
>  drivers/isdn/hardware/mISDN/hfcpci.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/isdn/hardware/mISDN/hfcpci.c b/drivers/isdn/hardware/mISDN/hfcpci.c
> index 7f910c7..5b8df75b 100644
> --- a/drivers/isdn/hardware/mISDN/hfcpci.c
> +++ b/drivers/isdn/hardware/mISDN/hfcpci.c
> @@ -2295,7 +2295,9 @@ _hfcpci_softirq(struct device *dev, void *arg)
>  static void
>  hfcpci_softirq(void *arg)
>  {
> -	(void) driver_for_each_device(&hfc_driver.driver, NULL, arg,
> +	int ret;
> +
> +	ret = driver_for_each_device(&hfc_driver.driver, NULL, arg,
>  				      _hfcpci_softirq);
>  
>  	/* if next event would be in the past ... */

This can result in a new compiler warning because ret is not used after
it is assigned.  Maybe add WARN_ON(ret)?

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
