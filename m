From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] TCP: Add support for TCP Stealth
Date: Thu, 1 Jan 2015 11:10:30 -0800
Message-ID: <20150101111030.1e2b3a18@urahara>
References: <54A470B3.3010501@sec.in.tum.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Christian Grothoff <christian@grothoff.org>,
	Jacob Appelbaum <jacob@appelbaum.net>
To: Julian Kirsch <kirschju@sec.in.tum.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:41388 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751468AbbAATKj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Jan 2015 14:10:39 -0500
Received: by mail-pa0-f53.google.com with SMTP id kq14so22993644pab.12
        for <netdev@vger.kernel.org>; Thu, 01 Jan 2015 11:10:39 -0800 (PST)
In-Reply-To: <54A470B3.3010501@sec.in.tum.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 31 Dec 2014 22:54:59 +0100
Julian Kirsch <kirschju@sec.in.tum.de> wrote:

> +	memcpy(iv, (const __u8 *)daddr,
> +	       (daddr_size > sizeof(iv)) ? sizeof(iv) : daddr_size);
> +
> +#ifdef CONFIG_TCP_MD5SIG
> +	md5 = tp->af_specific->md5_lookup(sk, sk);
> +#else
> +	md5 = NULL;
> +#endif
> +	if (likely(sysctl_tcp_timestamps && !md5) || tp->stealth.saw_tsval)
> +		tsval = tp->stealth.mstamp.stamp_jiffies;
> +
> +	((__be16 *)iv)[2] ^= cpu_to_be16(tp->stealth.integrity_hash);

Cast unnecessary on memcpy arg since it takes void *

Would be clearer to use a real structure or union not assignment to cast to setup iv.
