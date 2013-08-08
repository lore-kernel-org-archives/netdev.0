From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH v3 1/2] realtek: convert to per-chip mask
Date: Thu, 8 Aug 2013 20:25:41 +0200
Message-ID: <1375986341.2853.52.camel@deadeye.wl.decadent.org.uk>
References: <1374759391-16916-1-git-send-email-lekensteyn@gmail.com>
	 <1374759391-16916-2-git-send-email-lekensteyn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, Francois Romieu <romieu@fr.zoreil.com>
To: Peter Wu <lekensteyn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:6845 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758006Ab3HHSZq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Aug 2013 14:25:46 -0400
In-Reply-To: <1374759391-16916-2-git-send-email-lekensteyn@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-07-25 at 15:36 +0200, Peter Wu wrote:
[...]
> @@ -35,36 +32,62 @@ enum chip_type {
>  	RTL8100E2,
>  };
>  
> -enum {
> -	chip_type_mask = HW_REVID(1, 1, 1, 1, 1, 1, 1, 1)
> +static const char * const chip_names[] = {
> +	[RTL8139] =		"8139",
> +	[RTL8139_K] =		"8139-K",
> +	[RTL8139A] =		"8139A",
> +	[RTL8139A_G] =		"8139A-G",
> +	[RTL8139B] =		"8139B",
> +	[RTL8130] =		"8130",
> +	[RTL8139C] =		"8139C",
> +	[RTL8100] =		"8100",
> +	[RTL8100B_8139D] =	"8100B/8139D",
> +	[RTL8139C] =		"8139C+",

Shouldn't the index here be RTL8139Cp?

[...]
>  static struct chip_info {
> -	const char *name;
>  	u32 id_mask;
> +	u32 id_val;
> +	int mac_version;
>  } rtl_info_tbl[] = {
[...]
> -	{ "RTL-8169/8110SCe",	HW_REVID(1, 0, 0, 1, 1, 0, 0, 0) },
[...]
> +	{ 0xfcc00000, 0x68000000,	RTL8169_8110SCe },
[...]

The old value would be converted to 0x98000000; is this a fix or a
mistake?

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
