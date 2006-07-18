From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH 32/33] Add the Xen virtual network device driver.
Date: Tue, 18 Jul 2006 13:42:19 -0700 (PDT)
Message-ID: <20060718.134219.48395353.davem@davemloft.net>
References: <20060718091807.467468000@sous-sol.org>
	<20060718091958.414414000@sous-sol.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, virtualization@lists.osdl.org,
	xen-devel@lists.xensource.com, jeremy@goop.org, ak@suse.de,
	akpm@osdl.org, rusty@rustcorp.com.au, zach@vmware.com,
	ian.pratt@xensource.com, Christian.Limpach@cl.cam.ac.uk,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:17344
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932337AbWGRUl5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Jul 2006 16:41:57 -0400
To: chrisw@sous-sol.org
In-Reply-To: <20060718091958.414414000@sous-sol.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Chris Wright <chrisw@sous-sol.org>
Date: Tue, 18 Jul 2006 00:00:32 -0700

> +#ifdef CONFIG_XEN_BALLOON
> +#include <xen/balloon.h>
> +#endif

Let's put the ifdefs in xen/balloon.h not in the files
including it.

> +#ifdef CONFIG_XEN_BALLOON
> +	/* Tell the ballon driver what is going on. */
> +	balloon_update_driver_allowance(i);
> +#endif

Similarly let's define empty do-nothing functions in
xen/balloon.h when the config option isn't set so we
don't need to crap up the C sources with these ifdefs.
