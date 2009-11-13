From: Joe Perches <joe@perches.com>
Subject: Re: [net-next-2.6 PATCH v6 2/7 RFC] TCPCT part 1b: generate
 Responder Cookie
Date: Thu, 12 Nov 2009 22:26:34 -0800
Message-ID: <1258093594.16857.43.camel@Joe-Laptop.home>
References: <4AFCDA9E.8050003@gmail.com>  <4AFCDDC4.1090606@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: William Allen Simpson <william.allen.simpson@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1036 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752238AbZKMG0a (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Nov 2009 01:26:30 -0500
In-Reply-To: <4AFCDDC4.1090606@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2009-11-12 at 23:17 -0500, William Allen Simpson wrote:
> +int tcp_cookie_generator(u32 *bakery)
> +{
> +	unsigned long jiffy = jiffies;
> +
> +	if (unlikely(time_after_eq(jiffy, tcp_secret_generating->expires))) {
> +		spin_lock_bh(&tcp_secret_locker);
> +		if (!time_after_eq(jiffy, tcp_secret_generating->expires)) {
> +			/* refreshed by another */
> +			spin_unlock_bh(&tcp_secret_locker);
> +			memcpy(bakery,
> +			       &tcp_secret_generating->secrets[0],
> +			       sizeof(tcp_secret_generating->secrets));
> +		} else {
> +			u32 secrets[COOKIE_WORKSPACE_WORDS];

Rather than using stack, could you use
u32 *secrets = &tcp_secret_secondary->secrets[0];


