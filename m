From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH RFC 1/2] tun: don't require serialization lock on tx
Date: Wed, 13 Apr 2016 06:27:08 -0700
Message-ID: <1460554028.10638.18.camel@edumazet-glaptop3.roam.corp.google.com>
References: <cover.1460393493.git.pabeni@redhat.com>
	 <425e8f69ffd8fe315ef9d3cc678519c7060fb2e0.1460393493.git.pabeni@redhat.com>
	 <20160413123828-mutt-send-email-mst@redhat.com>
	 <570E15D9.4000308@stressinduktion.org>
	 <20160413155654-mutt-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Paolo Abeni <pabeni@redhat.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Greg Kurz <gkurz@linux.vnet.ibm.com>,
	Jason Wang <jasowang@redhat.com>,
	Christian Borntraeger <borntraeger@de.ibm.com>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:36440 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759796AbcDMN1L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Apr 2016 09:27:11 -0400
Received: by mail-pa0-f48.google.com with SMTP id er2so5041290pad.3
        for <netdev@vger.kernel.org>; Wed, 13 Apr 2016 06:27:11 -0700 (PDT)
In-Reply-To: <20160413155654-mutt-send-email-mst@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

     I. On Wed, 2016-04-13 at 15:57 +0300, Michael S. Tsirkin wrote:

> Fine, but what's the AF_PACKET duplication that Herbert Xu
> reported with NETIF_F_LLTX? Does anyone remember?

Really a lot of virtual drivers use NETIF_F_LLTX these days.

Duplication is more likely to happen with a qdisc, when a packet is
requeued if a driver returns NETDEV_TX_BUSY
