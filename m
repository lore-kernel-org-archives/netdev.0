From: Paul Durrant <Paul.Durrant@citrix.com>
Subject: RE: [Xen PATCH] xen-netback: fix error handling output
Date: Tue, 8 Nov 2016 13:40:02 +0000
Message-ID: <f38572a35c244b2bad7c8e2dde890c75@AMSPEX02CL03.citrite.net>
References: <20161108133449.1649345-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Wei Liu <wei.liu2@citrix.com>,
        "David S. Miller" <davem@davemloft.net>,
        Juergen Gross <jgross@suse.com>,
        Filipe Manco <filipe.manco@neclab.eu>,
        "xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Arnd Bergmann <arnd@arndb.de>,
        David Vrabel <david.vrabel@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([185.25.65.24]:17866 "EHLO
        SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751243AbcKHNkS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 8 Nov 2016 08:40:18 -0500
In-Reply-To: <20161108133449.1649345-1-arnd@arndb.de>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Arnd Bergmann [mailto:arnd@arndb.de]
> Sent: 08 November 2016 13:35
> To: David Vrabel <david.vrabel@citrix.com>
> Cc: Arnd Bergmann <arnd@arndb.de>; Wei Liu <wei.liu2@citrix.com>; Paul
> Durrant <Paul.Durrant@citrix.com>; David S. Miller
> <davem@davemloft.net>; Juergen Gross <jgross@suse.com>; Filipe Manco
> <filipe.manco@neclab.eu>; xen-devel@lists.xenproject.org;
> netdev@vger.kernel.org; linux-kernel@vger.kernel.org
> Subject: [Xen PATCH] xen-netback: fix error handling output
> 
> The connect function prints an unintialized error code after an
> earlier initialization was removed:
> 
> drivers/net/xen-netback/xenbus.c: In function 'connect':
> drivers/net/xen-netback/xenbus.c:938:3: error: 'err' may be used
> uninitialized in this function [-Werror=maybe-uninitialized]
> 
> This prints it as -EINVAL instead, which seems to be the most
> appropriate error code. Before the patch that caused the warning,
> this would print a positive number returned by vsscanf() instead,
> which is also wrong. We probably don't need a backport though,
> as fixing the warning here should be sufficient.
> 
> Fixes: f95842e7a9f2 ("xen: make use of xenbus_read_unsigned() in xen-
> netback")
> Fixes: 8d3d53b3e433 ("xen-netback: Add support for multiple queues")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Yes, I'd say EINVAL was most appropriate.

Reviewed-by: Paul Durrant <paul.durrant@citrix.com>

> ---
>  drivers/net/xen-netback/xenbus.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/xen-netback/xenbus.c b/drivers/net/xen-
> netback/xenbus.c
> index 7356e00fac54..bfed79877b8a 100644
> --- a/drivers/net/xen-netback/xenbus.c
> +++ b/drivers/net/xen-netback/xenbus.c
> @@ -935,7 +935,7 @@ static void connect(struct backend_info *be)
>  					"multi-queue-num-queues", 1);
>  	if (requested_num_queues > xenvif_max_queues) {
>  		/* buggy or malicious guest */
> -		xenbus_dev_fatal(dev, err,
> +		xenbus_dev_fatal(dev, -EINVAL,
>  				 "guest requested %u queues, exceeding the
> maximum of %u.",
>  				 requested_num_queues,
> xenvif_max_queues);
>  		return;
> --
> 2.9.0
