From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/2] net: netem: always adjust now/delay when not
 reordering
Date: Wed, 21 Aug 2013 10:00:17 -0700
Message-ID: <1377104417.4226.133.camel@edumazet-glaptop>
References: <1377011469-26151-1-git-send-email-mailings@hupie.com>
	  <1377011469-26151-2-git-send-email-mailings@hupie.com>
	  <5214D9F2.90900@stusta.de> <1377099575.4226.120.camel@edumazet-glaptop>
	 <5214E774.8060400@hupie.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Johannes Naab <jn@stusta.de>, netdev@vger.kernel.org,
	hagen@jauu.net
To: Ferry Huberts <mailings@hupie.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f173.google.com ([209.85.214.173]:48685 "EHLO
	mail-ob0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751519Ab3HURAV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Aug 2013 13:00:21 -0400
Received: by mail-ob0-f173.google.com with SMTP id ta17so1313323obb.18
        for <netdev@vger.kernel.org>; Wed, 21 Aug 2013 10:00:20 -0700 (PDT)
In-Reply-To: <5214E774.8060400@hupie.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-08-21 at 18:14 +0200, Ferry Huberts wrote:

> Well no. We expected no reordering because reordering is not enabled.


Sending packets with random delays happening in the 'network' _will_
reorder packets at the receiver.

The 'reorder' netem attribute is quite limited and not practical,
because it only queues the packet at the head of the queue instead of
tail. This is not what happens on the networks.

You want something very special, and this needs a new parameter to netem
qdisc, or a new qdisc.

If I setup "netem rate 1Mbit delay 1000ms 50ms", and send a burst of 100
small packets, I expect these _all_ packets reach the destination in
less than 1050ms.

I do not want packet1 being delivered at t0+1020ms,
packet2 being delivered at t0+1020+1030ms
packet100 being delivered at t0+1020+1030++...+ = t0+~100sec

If your patch solves the problem, good, but I see no clear test of this.
