From: Paul Durrant <Paul.Durrant@citrix.com>
Subject: RE: [PATCH V6 net-next 5/5] xen-net{back,front}: Document
 multi-queue feature in netif.h
Date: Mon, 3 Mar 2014 12:53:03 +0000
Message-ID: <9AAE0902D5BC7E449B7C8E4E778ABCD0261160@AMSPEX01CL01.citrite.net>
References: <1393847269-6981-1-git-send-email-andrew.bennieston@citrix.com>
 <1393847269-6981-6-git-send-email-andrew.bennieston@citrix.com>
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
Received: from smtp.ctxuk.citrix.com ([185.25.65.24]:38556 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753541AbaCCMx1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Mar 2014 07:53:27 -0500
In-Reply-To: <1393847269-6981-6-git-send-email-andrew.bennieston@citrix.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Andrew J. Bennieston [mailto:andrew.bennieston@citrix.com]
> Sent: 03 March 2014 11:48
> To: xen-devel@lists.xenproject.org
> Cc: Ian Campbell; Wei Liu; Paul Durrant; netdev@vger.kernel.org; David
> Vrabel; Andrew Bennieston
> Subject: [PATCH V6 net-next 5/5] xen-net{back,front}: Document multi-
> queue feature in netif.h
> 
> From: "Andrew J. Bennieston" <andrew.bennieston@citrix.com>
> 
> Document the multi-queue feature in terms of XenStore keys to be written
> by the backend and by the frontend.
> 
> Signed-off-by: Andrew J. Bennieston <andrew.bennieston@citrix.com>

Reviewed-by: Paul Durrant <paul.durrant@citrix.com>

> ---
>  include/xen/interface/io/netif.h |   29 +++++++++++++++++++++++++++++
>  1 file changed, 29 insertions(+)
> 
> diff --git a/include/xen/interface/io/netif.h
> b/include/xen/interface/io/netif.h
> index c50061d..a375a75 100644
> --- a/include/xen/interface/io/netif.h
> +++ b/include/xen/interface/io/netif.h
> @@ -51,6 +51,35 @@
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
> + * "feature-split-event-channels" may be used when using multiple queues.
> + * Each queue consists of one shared ring pair, i.e. there must be the same
> + * number of tx and rx rings.
> + *
> + * For frontends requesting just one queue, the usual event-channel and
> + * ring-ref keys are written as before, simplifying the backend processing
> + * to avoid distinguishing between a frontend that doesn't understand the
> + * multi-queue feature, and one that does, but requested only one queue.
> + *
> + * Frontends requesting two or more queues must not write the toplevel
> + * event-channel (or event-channel-{tx,rx}) and {tx,rx}-ring-ref keys,
> + * instead writing them under sub-keys having the name "queue-N" where
> + * N is the integer ID of the queue for which those keys belong. Queues
> + * are indexed from zero.
> + *
> + * Mapping of packets to queues is considered to be a function of the
> + * transmitting system (backend or frontend) and is not negotiated
> + * between the two. Guests are free to transmit packets on any queue
> + * they choose, provided it has been set up correctly.
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
