From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 2/3] virtio-net: use per-receive queue page
 frag alloc for mergeable bufs
Date: Thu, 26 Dec 2013 14:00:58 -0800
Message-ID: <1388095258.12212.37.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1387239389-13216-1-git-send-email-mwdalton@google.com>
	 <1387239389-13216-2-git-send-email-mwdalton@google.com>
	 <52B7F065.3010707@redhat.com>
	 <1387819627.12212.4.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131223193704.GC1582@redhat.com>
	 <CANJ5vPLEV_Z-D-0tThwhWXbHVaRWOLv566Xk1eD4TNYqNvknHw@mail.gmail.com>
	 <20131226213727.GA10259@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Michael Dalton <mwdalton@google.com>,
	Jason Wang <jasowang@redhat.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Eric Dumazet <edumazet@google.com>,
	Rusty Russell <rusty@rustcorp.com.au>,
	lf-virt <virtualization@lists.linux-foundation.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f53.google.com ([209.85.160.53]:50449 "EHLO
	mail-pb0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752140Ab3LZWBA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Dec 2013 17:01:00 -0500
Received: by mail-pb0-f53.google.com with SMTP id ma3so8517086pbc.26
        for <netdev@vger.kernel.org>; Thu, 26 Dec 2013 14:00:59 -0800 (PST)
In-Reply-To: <20131226213727.GA10259@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-12-26 at 23:37 +0200, Michael S. Tsirkin wrote:

> Interesting. But if we can't allocate a buffer how can we
> do network processing?

How typical NIC drivers handle this case ?

Answer : nothing special should happen, we drop incoming traffic,
and make sure the driver recovers properly. (like not NULL deref or
crazy things like that)

Why virtio_net should be different ?

> 
> If we can reproduce the problem, we can maybe move
> allocation out of napi disabled section, but then
> we'll need to add more locking.

More exactly, use appropriate locking ;)
