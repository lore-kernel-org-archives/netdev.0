From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [Xen-devel] [PATCH 2/2] xen-netfront: recreate queues correctly
 when reconnecting
Date: Wed, 18 Jun 2014 15:25:09 +0100
Message-ID: <20140618142509.GE20819@zion.uk.xensource.com>
References: <1403084848-12872-1-git-send-email-david.vrabel@citrix.com>
 <1403084848-12872-3-git-send-email-david.vrabel@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <xen-devel@lists.xenproject.org>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	<wei.liu2@citrix.com>
To: David Vrabel <david.vrabel@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:23386 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756911AbaFROZK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Jun 2014 10:25:10 -0400
Content-Disposition: inline
In-Reply-To: <1403084848-12872-3-git-send-email-david.vrabel@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 18, 2014 at 10:47:28AM +0100, David Vrabel wrote:
> When reconnecting to the backend (after a resume/migration, for example),
> a different number of queues may be required (since the guest may have
> moved to a different host with different capabilities).  During the
> reconnection the old queues are torn down and new ones created.
> 
> Introduce xennet_create_queues() and xennet_destroy_queues() that fixes
> three bugs during the reconnection.
> 
> - The old info->queues was leaked.
> - The old queue's napi instances were not deleted.
> - The new queue's napi instances were left disabled (which meant no
>   packets could be received).
> 
> The xennet_destroy_queues() calls is deferred until the reconnection
> instead of the disconnection (in xennet_disconnect_backend()) because
> napi_disable() might sleep.
> 
> Signed-off-by: David Vrabel <david.vrabel@citrix.com>

Reviewed-by: Wei Liu <wei.liu2@citrix.com>

> ---
>  drivers/net/xen-netfront.c |  104 ++++++++++++++++++++++++++++++--------------
>  1 file changed, 72 insertions(+), 32 deletions(-)
