From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] net/smsc911x: Fix deferred probe for interrupt
Date: Sun, 30 Aug 2015 00:33:52 +0300
Message-ID: <55E22540.3060307@cogentembedded.com>
References: <1440787815-24655-1-git-send-email-tony@atomide.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-omap@vger.kernel.org,
	Steve Glendinning <steve.glendinning@shawell.net>
To: Tony Lindgren <tony@atomide.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f170.google.com ([209.85.217.170]:33084 "EHLO
	mail-lb0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752422AbbH2Vdy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Aug 2015 17:33:54 -0400
Received: by lbbsx3 with SMTP id sx3so45263303lbb.0
        for <netdev@vger.kernel.org>; Sat, 29 Aug 2015 14:33:52 -0700 (PDT)
In-Reply-To: <1440787815-24655-1-git-send-email-tony@atomide.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 8/28/2015 9:50 PM, Tony Lindgren wrote:

> The interrupt handler may not be available when smsc911x probes if the
> interrupt handler is a GPIO controller for example. Let's fix that
> by adding handling for -EPROBE_DEFER.

> Cc: Steve Glendinning <steve.glendinning@shawell.net>
> Signed-off-by: Tony Lindgren <tony@atomide.com>
> ---
>   drivers/net/ethernet/smsc/smsc911x.c | 5 ++++-
>   1 file changed, 4 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/smsc/smsc911x.c b/drivers/net/ethernet/smsc/smsc911x.c
> index 959aeea..cb9f166f 100644
> --- a/drivers/net/ethernet/smsc/smsc911x.c
> +++ b/drivers/net/ethernet/smsc/smsc911x.c
> @@ -2435,7 +2435,10 @@ static int smsc911x_drv_probe(struct platform_device *pdev)
>   	res_size = resource_size(res);
>
>   	irq = platform_get_irq(pdev, 0);
> -	if (irq <= 0) {
> +	if (irq == -EPROBE_DEFER) {
> +		retval = -EPROBE_DEFER;
> +		goto out_0;
> +	} else if (irq <= 0) {
>   		pr_warn("Could not allocate irq resource\n");
>   		retval = -ENODEV;

    I'd propagate the error code from platfrom_get_irq() instead (in fact, 
I've submitted a couple of such patches yesterday and they have been already 
merged).

[...]

NBR, Sergei
