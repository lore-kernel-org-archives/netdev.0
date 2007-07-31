From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v3 -mm 9/9] netconsole: Support dynamic reconfiguration
 using configfs
Date: Mon, 30 Jul 2007 17:13:06 -0700
Message-ID: <20070730171306.49b49818.akpm@linux-foundation.org>
References: <20070730024741.10828.48209.sendpatchset@enigma.security.iitk.ac.in>
	<20070730024910.10828.44721.sendpatchset@enigma.security.iitk.ac.in>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Keiichi Kii <k-keiichi@bx.jp.nec.com>,
	Netdev <netdev@vger.kernel.org>,
	Joel Becker <joel.becker@oracle.com>,
	Matt Mackall <mpm@selenic.com>,
	David Miller <davem@davemloft.net>
To: Satyam Sharma <satyam@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:38001 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934671AbXGaAOE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jul 2007 20:14:04 -0400
In-Reply-To: <20070730024910.10828.44721.sendpatchset@enigma.security.iitk.ac.in>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 30 Jul 2007 08:19:10 +0530
Satyam Sharma <satyam@infradead.org> wrote:

> +/*
> + * Wrapper over simple_strtol (base 10) with sanity and range checking.
> + * We return (signed) long only because we may want to return errors.
> + * Do not use this to convert numbers that are allowed to be negative.
> + */
> +static long strtol10_check_range(const char *cp, long min, long max)
> +{
> +	long ret;
> +	char *p = (char *) cp;
> +
> +	WARN_ON(min < 0);
> +	WARN_ON(max < min);
> +
> +	ret = simple_strtol(p, &p, 10);
> +
> +	if (*p && (*p != '\n')) {
> +		printk(KERN_ERR "netconsole: invalid input\n");
> +		return -EINVAL;
> +	}
> +	if ((ret < min) || (ret > max)) {
> +		printk(KERN_ERR "netconsole: input %ld must be between "
> +				"%ld and %ld\n", ret, min, max);
> +		return -EINVAL;
> +	}
> +
> +	return ret;
> +}

There's probably other code around the place which does this.  It might
be worth making this function a general-purpose thing.
