From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH RFC 1/2] tun: don't require serialization lock on tx
Date: Wed, 13 Apr 2016 16:54:34 +0300
Message-ID: <20160413165240-mutt-send-email-mst@redhat.com>
References: <cover.1460393493.git.pabeni@redhat.com>
 <425e8f69ffd8fe315ef9d3cc678519c7060fb2e0.1460393493.git.pabeni@redhat.com>
 <20160413123828-mutt-send-email-mst@redhat.com>
 <570E15D9.4000308@stressinduktion.org>
 <20160413155654-mutt-send-email-mst@redhat.com>
 <1460554028.10638.18.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Paolo Abeni <pabeni@redhat.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Greg Kurz <gkurz@linux.vnet.ibm.com>,
	Jason Wang <jasowang@redhat.com>,
	Christian Borntraeger <borntraeger@de.ibm.com>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50715 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757460AbcDMNyj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Apr 2016 09:54:39 -0400
Content-Disposition: inline
In-Reply-To: <1460554028.10638.18.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 13, 2016 at 06:27:08AM -0700, Eric Dumazet wrote:
>      I. On Wed, 2016-04-13 at 15:57 +0300, Michael S. Tsirkin wrote:
> 
> > Fine, but what's the AF_PACKET duplication that Herbert Xu
> > reported with NETIF_F_LLTX? Does anyone remember?
> 
> Really a lot of virtual drivers use NETIF_F_LLTX these days.
> 
> Duplication is more likely to happen with a qdisc, when a packet is
> requeued if a driver returns NETDEV_TX_BUSY

OK, now I understand what the duplication is about.
What about NETDEV_TX_LOCKED? Looks like it might have
the same effect?

This might be worth documenting in include/linux/netdevice.h,
might it not?


-- 
MST
