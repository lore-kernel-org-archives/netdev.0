From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v2 1/2] net/xen-netfront: Correct printf
 format in xennet_get_responses
Date: Wed, 03 Jun 2015 10:06:36 -0700
Message-ID: <1433351196.4861.131.camel@perches.com>
References: <1433350510-12846-1-git-send-email-julien.grall@citrix.com>
	<1433350510-12846-2-git-send-email-julien.grall@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: ian.campbell@citrix.com, netdev@vger.kernel.org,
	stefano.stabellini@eu.citrix.com, linux-kernel@vger.kernel.org,
	David Vrabel <david.vrabel@citrix.com>, xen-devel@lists.xenproject.org,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>
To: Julien Grall <julien.grall@citrix.com>
Return-path: <xen-devel-bounces@lists.xen.org>
In-Reply-To: <1433350510-12846-2-git-send-email-julien.grall@citrix.com>
List-Unsubscribe: <http://lists.xen.org/cgi-bin/mailman/options/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xen.org>
List-Help: <mailto:xen-devel-request@lists.xen.org?subject=help>
List-Subscribe: <http://lists.xen.org/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=subscribe>
Sender: xen-devel-bounces@lists.xen.org
Errors-To: xen-devel-bounces@lists.xen.org
List-Id: netdev.vger.kernel.org

On Wed, 2015-06-03 at 17:55 +0100, Julien Grall wrote:
> rx->status is an int16_t, print it using %d rather than %u in order to
> have a meaningful value when the field is negative.
[]
> diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
[]
> @@ -733,7 +733,7 @@ static int xennet_get_responses(struct netfront_queue *queue,
>  		if (unlikely(rx->status < 0 ||
>  			     rx->offset + rx->status > PAGE_SIZE)) {
>  			if (net_ratelimit())
> -				dev_warn(dev, "rx->offset: %x, size: %u\n",
> +				dev_warn(dev, "rx->offset: %x, size: %d\n",

If you're going to do this, perhaps it'd be sensible to
also change the %x to %#x or 0x%x so that people don't
mistake offset without an [a-f] for decimal.

>  					 rx->offset, rx->status);
