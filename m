From: Paul Durrant <Paul.Durrant@citrix.com>
Subject: RE: [PATCH V4 net-next 5/5] xen-net{back,front}: Document
 multi-queue feature in netif.h
Date: Fri, 21 Feb 2014 12:22:19 +0000
Message-ID: <9AAE0902D5BC7E449B7C8E4E778ABCD0255359@AMSPEX01CL01.citrite.net>
References: <1392659880-2538-1-git-send-email-andrew.bennieston@citrix.com>
 <1392659880-2538-6-git-send-email-andrew.bennieston@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Ian Campbell <Ian.Campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Vrabel <david.vrabel@citrix.com>,
	Andrew Bennieston <andrew.bennieston@citrix.com>
To: Andrew Bennieston <andrew.bennieston@citrix.com>,
	"xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([185.25.65.24]:12706 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754740AbaBUMWV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Feb 2014 07:22:21 -0500
In-Reply-To: <1392659880-2538-6-git-send-email-andrew.bennieston@citrix.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Andrew J. Bennieston [mailto:andrew.bennieston@citrix.com]
> Sent: 17 February 2014 17:58
> To: xen-devel@lists.xenproject.org
> Cc: Ian Campbell; Wei Liu; Paul Durrant; netdev@vger.kernel.org; David
> Vrabel; Andrew Bennieston
> Subject: [PATCH V4 net-next 5/5] xen-net{back,front}: Document multi-
> queue feature in netif.h
> 
> From: "Andrew J. Bennieston" <andrew.bennieston@citrix.com>
> 
> Document the multi-queue feature in terms of XenStore keys to be written
> by the backend and by the frontend.
> 
> Signed-off-by: Andrew J. Bennieston <andrew.bennieston@citrix.com>
> ---
>  include/xen/interface/io/netif.h |   21 +++++++++++++++++++++
>  1 file changed, 21 insertions(+)
> 
> diff --git a/include/xen/interface/io/netif.h
> b/include/xen/interface/io/netif.h
> index c50061d..8868c51 100644
> --- a/include/xen/interface/io/netif.h
> +++ b/include/xen/interface/io/netif.h
> @@ -51,6 +51,27 @@
>   */
> 
>  /*
> + * Multiple transmit and receive queues:
> + * If supported, the backend will write "multi-queue-max-queues" and set
> its
> + * value to the maximum supported number of queues.
> + * Frontends that are aware of this feature and wish to use it can write the
> + * key "multi-queue-num-queues", set to the number they wish to use.
> + *
> + * Queues replicate the shared rings and event channels, and
> + * "feature-split-event-channels" is required when using multiple queues.
> + *

Is it? The code in patch 2 appears to cope with the "event-channel" key as well as the split variants regardless of the number of queues being used. Am I missing some other restriction?

  Paul

> + * For frontends requesting just one queue, the usual event-channel and
> + * ring-ref keys are written as before, simplifying the backend processing
> + * to avoid distinguishing between a frontend that doesn't understand the
> + * multi-queue feature, and one that does, but requested only one queue.
> + *
> + * Frontends requesting two or more queues must not write the toplevel
> + * event-channel and ring-ref keys, instead writing them under sub-keys
> having
> + * the name "queue-N" where N is the integer ID of the queue for which
> those
> + * keys belong. Queues are indexed from zero.
> + */
> +
> +/*
>   * "feature-no-csum-offload" should be used to turn IPv4 TCP/UDP
> checksum
>   * offload off or on. If it is missing then the feature is assumed to be on.
>   * "feature-ipv6-csum-offload" should be used to turn IPv6 TCP/UDP
> checksum
> --
> 1.7.10.4
