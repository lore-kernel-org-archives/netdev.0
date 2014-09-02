From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH 2/3] qdisc: bulk dequeue support for qdiscs
 with TCQ_F_ONETXQUEUE
Date: Tue, 02 Sep 2014 08:22:42 -0700
Message-ID: <1409671362.3173.108.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140902143254.1918.8419.stgit@dragon>
	 <20140902143538.1918.82870.stgit@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Florian Westphal <fw@strlen.de>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Daniel Borkmann <dborkman@redhat.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:61224 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753703AbaIBPWr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Sep 2014 11:22:47 -0400
Received: by mail-pa0-f45.google.com with SMTP id bj1so14965550pad.18
        for <netdev@vger.kernel.org>; Tue, 02 Sep 2014 08:22:46 -0700 (PDT)
In-Reply-To: <20140902143538.1918.82870.stgit@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-09-02 at 16:35 +0200, Jesper Dangaard Brouer wrote:

> This is crazy fast. This measurement is actually "too-high" as
> 10Gbit/s wirespeed is 14,880,952 (11049 pps too fast).
> 
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
> ---

This looks buggy, you forgot about GSO.

(You did the test only for first dequeued packet, not the followings)

Make sure you test your patch with something else than pktgen.

Also, our idea was to use a byte count limit (aka BQL)

If we dequeue 8 64KB packets, this patch adds head of line blocking,
which we fought hard.
