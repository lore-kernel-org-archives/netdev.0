From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next] natsemi: fix legacy printk() style
Date: Thu, 24 Oct 2013 15:33:16 -0700
Message-ID: <1382653996.22433.84.camel@joe-AO722>
References: <1382650646-24009-1-git-send-email-quantumdude836@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Drew McGowen <quantumdude836@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0132.hostedemail.com ([216.40.44.132]:48111 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754558Ab3JXWdT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Oct 2013 18:33:19 -0400
In-Reply-To: <1382650646-24009-1-git-send-email-quantumdude836@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-10-24 at 21:37 +0000, Drew McGowen wrote:
> Fixed printk() calls to use KERN_* prefix (some were not changed because they
> are continuations of a previous line).
[]
> diff --git a/drivers/net/ethernet/natsemi/natsemi.c b/drivers/net/ethernet/natsemi/natsemi.c
[]
> @@ -814,7 +814,7 @@ static int natsemi_probe1(struct pci_dev *pdev, const struct pci_device_id *ent)
>  #ifndef MODULE
>  	static int printed_version;
>  	if (!printed_version++)
> -		printk(version);
> +		printk(KERN_INFO version);

pr_info_once("%s\n", version);

And remove the trailing newline from version

> @@ -3360,7 +3360,7 @@ static int __init natsemi_init_mod (void)
>  {
>  /* when a module, this is printed whether or not devices are found in probe */
>  #ifdef MODULE
> -	printk(version);
> +	printk(KERN_INFO version);

	pr_info("%s\n", version);

Nicer to use netdev_<level> too.
