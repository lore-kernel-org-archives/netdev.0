From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next] pkt_sched: fq: Fair Queue packet scheduler
Date: Tue, 03 Sep 2013 22:59:36 -0700
Message-ID: <1378274376.7360.82.camel@edumazet-glaptop>
References: <1377816595.8277.54.camel@edumazet-glaptop>
	 <5226C4A0.6040709@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	"Michael S. Tsirkin" <mst@redhat.com>
To: Jason Wang <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f53.google.com ([209.85.160.53]:61165 "EHLO
	mail-pb0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756079Ab3IDF7i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Sep 2013 01:59:38 -0400
Received: by mail-pb0-f53.google.com with SMTP id up15so6938651pbc.40
        for <netdev@vger.kernel.org>; Tue, 03 Sep 2013 22:59:38 -0700 (PDT)
In-Reply-To: <5226C4A0.6040709@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-09-04 at 13:26 +0800, Jason Wang wrote:

> I see both degradation and jitter when using fq with virtio-net. Guest
> to guest performance drops from 8Gb/s to 3Gb/s-7Gb/s. Guest to local
> host drops from 8Gb/s to 4Gb/s-6Gb/s. Guest to external host with ixgbe
> drops from 9Gb/s to 7Gb/s
> 
> I didn't meet the issue when using sfq or disabling pacing.
> 
> So it looks like it was caused by the inaccuracy and jitter of the
> pacing estimation in a virt guest?

Well, using virtio-net means you use FQ without pacing.

Make sure you do not have reorders because of a bug in queue selection.

TCP stack has the ooo_okay thing, I do not think a VM can get it.

nstat >/dev/null ; <your test> ; nstat

And tcpdump would certainly help ;)
