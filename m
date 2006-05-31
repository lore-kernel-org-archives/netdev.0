From: David Miller <davem@davemloft.net>
Subject: Re: netif_tx_disable and lockless TX
Date: Tue, 30 May 2006 21:13:22 -0700 (PDT)
Message-ID: <20060530.211322.51700292.davem@davemloft.net>
References: <20060531040307.GA6447@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com, jgarzik@pobox.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:10369
	"EHLO sunset.sfo1.dsl.speakeasy.net") by vger.kernel.org with ESMTP
	id S1751664AbWEaEMz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 May 2006 00:12:55 -0400
To: herbert@gondor.apana.org.au
In-Reply-To: <20060531040307.GA6447@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 31 May 2006 14:03:07 +1000

> I must say though that I'm becoming less and less impressed by the
> lockless feature based on the number of problems that it has caused.
> Does anyone have any hard figures as to its effectiveness (excluding
> any stats relating to the loopback interface which can be easily
> separated from normal NIC drivers).

There were numbers posted for real drivers at one point, I
do remember that, and the gains were non-trivial.  At least
enough to justify the feature.

As per the bug, I always keep thinking about changing how we
do the lockless stuff by simply making xmit_lock a pointer.
Drivers like tg3 can make it point to their local driver lock.

This leaves still the cases like loopback which do no locking
whatsoever.  I don't know how to fit it into the above idea.
