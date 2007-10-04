From: Alexey Dobriyan <adobriyan@sw.ru>
Subject: Re: [Devel] [PATCH][NETNS] Move some code into __init section when CONFIG_NET_NS=n
Date: Thu, 4 Oct 2007 18:02:02 +0400
Message-ID: <20071004140202.GA6180@localhost.sw.ru>
References: <4704F083.7090203@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.233.200]:47333 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756037AbXJDOCV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Oct 2007 10:02:21 -0400
Content-Disposition: inline
In-Reply-To: <4704F083.7090203@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 04, 2007 at 05:54:11PM +0400, Pavel Emelyanov wrote:
> With the net namespaces many code leaved the __init section,
> thus making the kernel occupy more memory than it did before.
> Since we have a config option that prohibits the namespace
> creation, the functions that initialize/finalize some netns
> stuff are simply not needed and can be freed after the boot.
> 
> Currently, this is almost not noticeable, since few calls
> are no longer in __init, but when the namespaces will be
> merged it will be possible to free more code. I propose to 
> use the __net_init, __net_exit and __net_initdata "attributes"
> for functions/variables that are not used if the CONFIG_NET_NS
> is not set to save more space in memory.

> +#ifdef CONFIG_NET_NS
> +#define __net_init
> +#define __net_exit
> +#define __net_initdata
> +#else
> +#define __net_init	__init
> +#define __net_exit	__exit
> +#define __net_initdata	__initdata
> +#endif

Yet another set of double-underscored section annotations is the last thing
that is needed, methinks. :)

