From: David Vrabel <david.vrabel@citrix.com>
Subject: Re: [Xen-devel] [PATCH V3 net-next 4/5] xen-netfront: Add support
 for	multiple queues
Date: Fri, 14 Feb 2014 18:11:45 +0000
Message-ID: <52FE5C61.6000807@citrix.com>
References: <1392399353-11973-1-git-send-email-andrew.bennieston@citrix.com> <1392399353-11973-5-git-send-email-andrew.bennieston@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <xen-devel@lists.xenproject.org>, <netdev@vger.kernel.org>,
	<paul.durrant@citrix.com>, <wei.liu2@citrix.com>,
	<ian.campbell@citrix.com>
To: "Andrew J. Bennieston" <andrew.bennieston@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:18653 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751757AbaBNSL6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Feb 2014 13:11:58 -0500
In-Reply-To: <1392399353-11973-5-git-send-email-andrew.bennieston@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 14/02/14 17:35, Andrew J. Bennieston wrote:
> From: "Andrew J. Bennieston" <andrew.bennieston@citrix.com>
> 
> Build on the refactoring of the previous patch to implement multiple
> queues between xen-netfront and xen-netback.
> 
> Check XenStore for multi-queue support, and set up the rings and event
> channels accordingly.
> 
> Write ring references and event channels to XenStore in a queue
> hierarchy if appropriate, or flat when using only one queue.
> 
> Update the xennet_select_queue() function to choose the queue on which
> to transmit a packet based on the skb hash result.
[...]
> --- a/drivers/net/xen-netfront.c
> +++ b/drivers/net/xen-netfront.c
> @@ -57,6 +57,10 @@
>  #include <xen/interface/memory.h>
>  #include <xen/interface/grant_table.h>
>  
> +/* Module parameters */
> +unsigned int xennet_max_queues;
> +module_param(xennet_max_queues, uint, 0644);

Module parameter should have some documentation with MODULE_PARAM_DESC()
or similar.

Otherwise,

Reviewed-by: David Vrabel <david.vrabel@citrix.com>

David
