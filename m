From: Juergen Gross <jgross@suse.com>
Subject: Re: [Xen PATCH] xen-netback: fix error handling output
Date: Thu, 10 Nov 2016 10:14:15 +0100
Message-ID: <f918b4f7-cf4f-34a1-0222-507beebe28a3@suse.com>
References: <20161108133449.1649345-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Wei Liu <wei.liu2@citrix.com>,
        Paul Durrant <paul.durrant@citrix.com>,
        "David S. Miller" <davem@davemloft.net>,
        Filipe Manco <filipe.manco@neclab.eu>,
        xen-devel@lists.xenproject.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>,
        David Vrabel <david.vrabel@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161108133449.1649345-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/11/16 14:34, Arnd Bergmann wrote:
> The connect function prints an unintialized error code after an
> earlier initialization was removed:
> 
> drivers/net/xen-netback/xenbus.c: In function 'connect':
> drivers/net/xen-netback/xenbus.c:938:3: error: 'err' may be used uninitialized in this function [-Werror=maybe-uninitialized]
> 
> This prints it as -EINVAL instead, which seems to be the most
> appropriate error code. Before the patch that caused the warning,
> this would print a positive number returned by vsscanf() instead,
> which is also wrong. We probably don't need a backport though,
> as fixing the warning here should be sufficient.
> 
> Fixes: f95842e7a9f2 ("xen: make use of xenbus_read_unsigned() in xen-netback")
> Fixes: 8d3d53b3e433 ("xen-netback: Add support for multiple queues")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Applied to xen/tip.git for-linus-4.10


Thanks,

Juergen

> ---
>  drivers/net/xen-netback/xenbus.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/xen-netback/xenbus.c b/drivers/net/xen-netback/xenbus.c
> index 7356e00fac54..bfed79877b8a 100644
> --- a/drivers/net/xen-netback/xenbus.c
> +++ b/drivers/net/xen-netback/xenbus.c
> @@ -935,7 +935,7 @@ static void connect(struct backend_info *be)
>  					"multi-queue-num-queues", 1);
>  	if (requested_num_queues > xenvif_max_queues) {
>  		/* buggy or malicious guest */
> -		xenbus_dev_fatal(dev, err,
> +		xenbus_dev_fatal(dev, -EINVAL,
>  				 "guest requested %u queues, exceeding the maximum of %u.",
>  				 requested_num_queues, xenvif_max_queues);
>  		return;
> 
