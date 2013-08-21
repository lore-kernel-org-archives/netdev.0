From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH 2/2] net: netem: always adjust now/delay when not
 reordering
Date: Wed, 21 Aug 2013 10:35:07 -0700
Message-ID: <20130821103507.3a499488@samsung-9>
References: <1377011469-26151-1-git-send-email-mailings@hupie.com>
	<1377011469-26151-2-git-send-email-mailings@hupie.com>
	<5214D9F2.90900@stusta.de>
	<1377099575.4226.120.camel@edumazet-glaptop>
	<5214E774.8060400@hupie.com>
	<1377104417.4226.133.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Ferry Huberts <mailings@hupie.com>, Johannes Naab <jn@stusta.de>,
	netdev@vger.kernel.org, hagen@jauu.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f181.google.com ([209.85.216.181]:63248 "EHLO
	mail-qc0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752337Ab3HURfP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Aug 2013 13:35:15 -0400
Received: by mail-qc0-f181.google.com with SMTP id k15so399133qcv.40
        for <netdev@vger.kernel.org>; Wed, 21 Aug 2013 10:35:14 -0700 (PDT)
In-Reply-To: <1377104417.4226.133.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 21 Aug 2013 10:00:17 -0700
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> On Wed, 2013-08-21 at 18:14 +0200, Ferry Huberts wrote:
> 
> > Well no. We expected no reordering because reordering is not enabled.
> 
> 
> Sending packets with random delays happening in the 'network' _will_
> reorder packets at the receiver.
> 
> The 'reorder' netem attribute is quite limited and not practical,
> because it only queues the packet at the head of the queue instead of
> tail. This is not what happens on the networks.
> 
> You want something very special, and this needs a new parameter to netem
> qdisc, or a new qdisc.
> 
> If I setup "netem rate 1Mbit delay 1000ms 50ms", and send a burst of 100
> small packets, I expect these _all_ packets reach the destination in
> less than 1050ms.
> 
> I do not want packet1 being delivered at t0+1020ms,
> packet2 being delivered at t0+1020+1030ms
> packet100 being delivered at t0+1020+1030++...+ = t0+~100sec
> 
> If your patch solves the problem, good, but I see no clear test of this.

The current behavior followed what NISTnet did. At the time, I wanted
NISTnet users to be able to use netem without a lot of surprises.
  http://www-x.antd.nist.gov/nistnet/
