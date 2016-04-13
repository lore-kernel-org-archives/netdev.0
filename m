From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH RFC 1/2] tun: don't require serialization lock on tx
Date: Wed, 13 Apr 2016 07:39:51 -0700
Message-ID: <1460558391.10638.24.camel@edumazet-glaptop3.roam.corp.google.com>
References: <cover.1460393493.git.pabeni@redhat.com>
	 <425e8f69ffd8fe315ef9d3cc678519c7060fb2e0.1460393493.git.pabeni@redhat.com>
	 <20160413123828-mutt-send-email-mst@redhat.com>
	 <570E15D9.4000308@stressinduktion.org>
	 <20160413155654-mutt-send-email-mst@redhat.com>
	 <1460554028.10638.18.camel@edumazet-glaptop3.roam.corp.google.com>
	 <20160413165240-mutt-send-email-mst@redhat.com>
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
Received: from mail-pa0-f43.google.com ([209.85.220.43]:34743 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753817AbcDMOjy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Apr 2016 10:39:54 -0400
Received: by mail-pa0-f43.google.com with SMTP id ot11so34607283pab.1
        for <netdev@vger.kernel.org>; Wed, 13 Apr 2016 07:39:53 -0700 (PDT)
In-Reply-To: <20160413165240-mutt-send-email-mst@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-04-13 at 16:54 +0300, Michael S. Tsirkin wrote:

> OK, now I understand what the duplication is about.
> What about NETDEV_TX_LOCKED? Looks like it might have
> the same effect?
> 
> This might be worth documenting in include/linux/netdevice.h,
> might it not?

I believe the intent is to get rid of NETDEV_TX_LOCKED at some point.

Some drivers seem to abuse it.

For example, drivers/infiniband/hw/nes/nes_nic.c is clearly completely
buggy :(
