From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH net-next 2/8] sfc: batch up RX delivery on EF10
Date: Tue, 19 Apr 2016 07:47:37 -0700
Message-ID: <1461077257.10638.185.camel@edumazet-glaptop3.roam.corp.google.com>
References: <5716338E.4050003@solarflare.com>
	 <57163404.2000507@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	linux-net-drivers@solarflare.com
To: Edward Cree <ecree@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:33640 "EHLO
	mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752986AbcDSOrj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2016 10:47:39 -0400
Received: by mail-pf0-f171.google.com with SMTP id 184so7610694pff.0
        for <netdev@vger.kernel.org>; Tue, 19 Apr 2016 07:47:38 -0700 (PDT)
In-Reply-To: <57163404.2000507@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-04-19 at 14:35 +0100, Edward Cree wrote:
> Improves packet rate of 1-byte UDP receives by 10%.

Sure, by adding yet another queue and extra latencies.

If the switch delivered a high prio packet to your host right before a
train of 60 low prio packets, this is not to allow us to wait the end of
the train.

We have to really invent something better, like a real pipeline, instead
of hacks like this, adding complexity everywhere.

Have you tested this on cpus with tiny caches, like 32KB ?
