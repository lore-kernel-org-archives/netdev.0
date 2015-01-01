From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] TCP: Add support for TCP Stealth
Date: Thu, 1 Jan 2015 11:06:46 -0800
Message-ID: <20150101110646.0b92a173@urahara>
References: <54A470B3.3010501@sec.in.tum.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Christian Grothoff <christian@grothoff.org>,
	Jacob Appelbaum <jacob@appelbaum.net>
To: Julian Kirsch <kirschju@sec.in.tum.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:55880 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750956AbbAATG5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Jan 2015 14:06:57 -0500
Received: by mail-pa0-f41.google.com with SMTP id rd3so22955857pab.14
        for <netdev@vger.kernel.org>; Thu, 01 Jan 2015 11:06:56 -0800 (PST)
In-Reply-To: <54A470B3.3010501@sec.in.tum.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 31 Dec 2014 22:54:59 +0100
Julian Kirsch <kirschju@sec.in.tum.de> wrote:

> +#ifdef CONFIG_TCP_STEALTH
> +/* Stealth TCP socket configuration */
> +	struct {
> +		#define TCP_STEALTH_MODE_AUTH		BIT(0)
> +		#define TCP_STEALTH_MODE_INTEGRITY	BIT(1)
> +		#define TCP_STEALTH_MODE_INTEGRITY_LEN	BIT(2)
> +		int mode;
> +		u8 secret[MD5_MESSAGE_BYTES];
> +		int integrity_len;
> +		u16 integrity_hash;
> +		struct skb_mstamp mstamp;
> +		bool saw_tsval;
> +	} stealth;
> +#endif

If you want a bitfield, why not use a bitfield for mode?
If you have to use masks, better to use u8 for mode.
Integrity length should be unsigned since obviously negative
values are not possible.

Rearrange structure to save space. Lots of holes here.
