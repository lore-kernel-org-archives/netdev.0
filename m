From: Anthony Liguori <anthony@codemonkey.ws>
Subject: Re: [PATCH 4/4] lguest: Use GSO/IFF_VNET_HDR extensions on tun/tap
Date: Wed, 25 Jun 2008 14:07:18 -0500
Message-ID: <48629766.4040905@codemonkey.ws>
References: <200806260028.07883.rusty@rustcorp.com.au>	<200806260029.40267.rusty@rustcorp.com.au>	<200806260030.38293.rusty@rustcorp.com.au> <200806260032.12359.rusty__46755.7742762894$1214404667$gmane$org@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Max Krasnyansky <maxk@qualcomm.com>, markmc@redhat.com,
	netdev@vger.kernel.org, Herbert Xu <herbert@gondor.apana.org.au>,
	virtualization@lists.linux-foundation.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.30]:8142 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752401AbYFYTHk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jun 2008 15:07:40 -0400
Received: by yx-out-2324.google.com with SMTP id 31so701312yxl.1
        for <netdev@vger.kernel.org>; Wed, 25 Jun 2008 12:07:39 -0700 (PDT)
In-Reply-To: <200806260032.12359.rusty__46755.7742762894$1214404667$gmane$org@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rusty Russell wrote:
> @@ -1563,6 +1561,16 @@ static void setup_tun_net(char *arg)
>  	/* Tell Guest what MAC address to use. */
>  	add_feature(dev, VIRTIO_NET_F_MAC);
>  	add_feature(dev, VIRTIO_F_NOTIFY_ON_EMPTY);
> +	/* Expect Guest to handle everything except UFO */
> +	add_feature(dev, VIRTIO_NET_F_CSUM);

You're setting this feature twice.

> +	add_feature(dev, VIRTIO_NET_F_GUEST_CSUM);

You set this feature, but I never see the virtio-net driver acknowledge 
the feature.  Curiously, my implementation with KVM is struggling 
because UDP packet checksums are not correct so the DHCP client is 
ignoring them.  If I disable CSUM offload, things it works fine (using 
the virtio-net header).  The problem is only host=>guest, guest=>host is 
fine.

Regards,

Anthony Liguori

