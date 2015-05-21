From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: ingress policying for realtime protocol
Date: Wed, 20 May 2015 17:30:40 -0700
Message-ID: <1432168240.4060.63.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20150519211145.GA23134@pengutronix.de>
	 <CAHA+R7N8wFKPzOR0EshWzcaTUd+ChMW0zb0=1go4oV_gxoAyiA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Uwe =?ISO-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>, netdev <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f172.google.com ([209.85.223.172]:34896 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754061AbbEUAam (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2015 20:30:42 -0400
Received: by iesa3 with SMTP id a3so52134563ies.2
        for <netdev@vger.kernel.org>; Wed, 20 May 2015 17:30:42 -0700 (PDT)
In-Reply-To: <CAHA+R7N8wFKPzOR0EshWzcaTUd+ChMW0zb0=1go4oV_gxoAyiA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-05-20 at 16:46 -0700, Cong Wang wrote:

> There is very little to do on ingress side since there is no queue at all,
> not to mention priority, you could try ifb to see if it fits your need.

Note that if the need is to police traffic, ifb is not really needed :

TC="tc"
DEV="dev eth0"
IP=10.246.11.51/32
$TC qdisc del $DEV ingress 2>/dev/null
$TC qdisc add $DEV ingress
$TC filter add $DEV parent ffff: protocol ip u32 match ip src $IP \
	police rate 1Mbit burst 10Mbit mtu 66000 action drop/continue

$TC -s filter ls $DEV parent ffff: protocol ip
