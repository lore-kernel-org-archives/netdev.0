From: Breno Leitao <brenohl@br.ibm.com>
Subject: Re: [PATCH] ehea: add alias entry for portN properties
Date: Wed, 02 May 2012 15:34:12 -0300
Message-ID: <4FA17E24.3020306@br.ibm.com>
References: <4FA17C4E.1030905@suse.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Jeff Mahoney <jeffm@suse.com>,
	Breno Leitao <leitao@linux.vnet.ibm.com>,
	Network Development <netdev@vger.kernel.org>,
	Olaf Hering <ohering@suse.com>
To: Thadeu Lima De Souza Cascardo <thadeul@br.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp03.br.ibm.com ([32.104.18.24]:55418 "EHLO
	e24smtp03.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755606Ab2EBSeS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 May 2012 14:34:18 -0400
Received: from /spool/local
	by e24smtp03.br.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <brenohl@br.ibm.com>;
	Wed, 2 May 2012 15:34:16 -0300
Received: from d24relay02.br.ibm.com (d24relay02.br.ibm.com [9.13.184.26])
	by d24dlp02.br.ibm.com (Postfix) with ESMTP id D517A1DC004D
	for <netdev@vger.kernel.org>; Wed,  2 May 2012 15:34:09 -0300 (BRT)
Received: from d24av04.br.ibm.com (d24av04.br.ibm.com [9.8.31.97])
	by d24relay02.br.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q42IXqg126739192
	for <netdev@vger.kernel.org>; Wed, 2 May 2012 15:33:52 -0300
Received: from d24av04.br.ibm.com (loopback [127.0.0.1])
	by d24av04.br.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q42GY17Y008790
	for <netdev@vger.kernel.org>; Wed, 2 May 2012 13:34:02 -0300
In-Reply-To: <4FA17C4E.1030905@suse.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thadeu,

Could you check this patch, please?

Thanks
On 05/02/2012 03:26 PM, Jeff Mahoney wrote:
> Use separate table for alias entries in the ehea module,
> otherwise the probe() function will operate on the separate ports
> instead of the lhea-"root" entry of the device-tree
> 
> Initially reported here:
> https://bugzilla.novell.com/show_bug.cgi?id=435215
> 
> Signed-off-by: Jeff Mahoney <jeffm@suse.com>
> Signed-off-by: Olaf Hering <ohering@suse.com>
> ---
>  drivers/net/ethernet/ibm/ehea/ehea_main.c |   14 +++++++++++++-
>  1 file changed, 13 insertions(+), 1 deletion(-)
> 
> --- a/drivers/net/ethernet/ibm/ehea/ehea_main.c
> +++ b/drivers/net/ethernet/ibm/ehea/ehea_main.c
> @@ -103,6 +103,19 @@ static int __devinit ehea_probe_adapter(
> 
>  static int __devexit ehea_remove(struct platform_device *dev);
> 
> +static struct of_device_id ehea_module_device_table[] = {
> +	{
> +		.name = "lhea",
> +		.compatible = "IBM,lhea",
> +	},
> +	{
> +		.type = "network",
> +		.compatible = "IBM,lhea-ethernet",
> +	},
> +	{},
> +};
> +MODULE_DEVICE_TABLE(of, ehea_module_device_table);
> +
>  static struct of_device_id ehea_device_table[] = {
>  	{
>  		.name = "lhea",
> @@ -110,7 +123,6 @@ static struct of_device_id ehea_device_t
>  	},
>  	{},
>  };
> -MODULE_DEVICE_TABLE(of, ehea_device_table);
> 
>  static struct of_platform_driver ehea_driver = {
>  	.driver = {
