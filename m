From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] ethtool: Add register dump support for all r8169
	driver cards
Date: Wed, 26 Mar 2008 22:44:32 +0100
Message-ID: <20080326214432.GA9356@electric-eye.fr.zoreil.com>
References: <76366b180803260519t7c446210n62d4c91209c5e971@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Jeff Garzik <jeff@garzik.org>
To: Andrew Paprocki <andrew@ishiboo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:34958 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760708AbYCZWCs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2008 18:02:48 -0400
Content-Disposition: inline
In-Reply-To: <76366b180803260519t7c446210n62d4c91209c5e971@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Paprocki <andrew@ishiboo.com> :
[...]
> diff --git a/realtek.c b/realtek.c
> index c56b3f5..7e750da 100644
> --- a/realtek.c
> +++ b/realtek.c
[...]
> @@ -157,9 +170,7 @@ realtek_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs)
>  		data[0x2C >> 2]);
>  	}
>  
> -	if (board_type == RTL8169 ||
> -	    board_type == RTL8169s ||
> -	    board_type == RTL8110) {
> +	if (board_type >= RTL8169) {
>  	fprintf(stdout,
>  		"0x30: Flash memory read/write                 0x%08x\n",
>  		data[0x30 >> 2]);

Please revert: this register is reserved in the 8168.

[...]
> @@ -272,9 +279,7 @@ realtek_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs)
>  		"0x5C: Multiple Interrupt Select                   0x%04x\n",
>  		data[0x5c >> 2] & 0xffff);
>  
> -	if (board_type == RTL8169 ||
> -	    board_type == RTL8169s ||
> -	    board_type == RTL8110) {
> +	if (board_type >= RTL8169) {
>  	fprintf(stdout,
>  		"0x60: PHY access                              0x%08x\n"
>  		"0x64: TBI control and status                  0x%08x\n",

PHY access and PHY status are ok for the 8168. TBI and PM registers are not.

[...]
> @@ -512,6 +514,16 @@ realtek_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs)
>  	fprintf(stdout,
>  		"0xFC: External MII register                   0x%08x\n",
>  		data[0xFC >> 2]);
> +	} else if (board_type >= RTL8169) {
> +	fprintf(stdout,
> +		"0xF0: Func Event                              0x%08x\n"
> +		"0xF4: Func Event Mask                         0x%08x\n"
> +		"0xF8: Func Preset State                       0x%08x\n"
> +		"0xFC: Func Force Event                        0x%08x\n",
> +		data[0xF0 >> 2],
> +		data[0xF4 >> 2],
> +		data[0xF8 >> 2],
> +		data[0xFC >> 2]);

The 8168 should not be included here.

-- 
Ueimor
