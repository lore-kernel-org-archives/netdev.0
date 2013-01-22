From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] ethtool: Add version check for et131x regs
Date: Tue, 22 Jan 2013 20:44:39 +0000
Message-ID: <1358887479.2892.22.camel@bwh-desktop.uk.solarflarecom.com>
References: <1357379851-5298-1-git-send-email-mark.einon@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Mark Einon <mark.einon@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:35205 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752136Ab3AVUom (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2013 15:44:42 -0500
In-Reply-To: <1357379851-5298-1-git-send-email-mark.einon@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2013-01-05 at 09:57 +0000, Mark Einon wrote:
> Added a version check for the et131x reg dump, in case the dump format
> needs to be changed later.
> 
> Signed-off-by: Mark Einon <mark.einon@gmail.com>
> ---
>  et131x.c |    4 ++++
>  1 file changed, 4 insertions(+)
> 
> diff --git a/et131x.c b/et131x.c
> index b36c184..8cdbec0 100644
> --- a/et131x.c
> +++ b/et131x.c
> @@ -4,8 +4,12 @@
>  
>  int et131x_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs)
>  {
> +	u8 version = (u8)(regs->version >> 24);
>  	u32 *reg = (u32 *)regs->data;
>  
> +	if(version != 1)

Needs a space before the open-parentheis.

Ben.

> +		return -1;
> +
>  	fprintf(stdout, "PHY Registers\n");
>  	fprintf(stdout, "0x0, Basic Control Reg          = 0x%04X\n", *reg++);
>  	fprintf(stdout, "0x1, Basic Status Reg           = 0x%04X\n", *reg++);

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
