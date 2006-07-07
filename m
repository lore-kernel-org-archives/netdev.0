From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 8/9] smsc-ircc2: fix section reference mismatches
Date: Fri, 07 Jul 2006 13:28:16 -0400
Message-ID: <44AE99B0.6040508@garzik.org>
References: <200607070658.k676wRh5030383@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dtor@insightbb.com, dtor@mail.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:14827 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S932188AbWGGR2S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Jul 2006 13:28:18 -0400
To: akpm@osdl.org
In-Reply-To: <200607070658.k676wRh5030383@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

akpm@osdl.org wrote:
> From: Dmitry Torokhov <dtor@insightbb.com>
> 
> subsystem_configurations array is only used by an __init function,
> therefore it should be marked __initdata, not __devinitdata.
> 
> Signed-off-by: Dmitry Torokhov <dtor@mail.ru>
> Signed-off-by: Andrew Morton <akpm@osdl.org>
> ---
> 
>  drivers/net/irda/smsc-ircc2.c |    2 +-
>  1 files changed, 1 insertion(+), 1 deletion(-)
> 
> diff -puN drivers/net/irda/smsc-ircc2.c~smsc-ircc2-fix-section-reference-mismatches drivers/net/irda/smsc-ircc2.c
> --- a/drivers/net/irda/smsc-ircc2.c~smsc-ircc2-fix-section-reference-mismatches
> +++ a/drivers/net/irda/smsc-ircc2.c
> @@ -2353,7 +2353,7 @@ static int __init smsc_superio_lpc(unsig
>  #ifdef CONFIG_PCI
>  #define PCIID_VENDOR_INTEL 0x8086
>  #define PCIID_VENDOR_ALI 0x10b9
> -static struct smsc_ircc_subsystem_configuration subsystem_configurations[] __devinitdata = {
> +static struct smsc_ircc_subsystem_configuration subsystem_configurations[] __initdata = {

Are you sure this fully solves the problem?

It seems like the functions referenced inside this are inappropriately 
marked as well...


