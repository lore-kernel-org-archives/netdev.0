From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] mlx4: give precise rx/tx bytes/packets counters
Date: Mon, 28 Nov 2016 14:57:43 -0800
Message-ID: <1480373863.18162.99.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1480088780.8455.543.camel@edumazet-glaptop3.roam.corp.google.com>
         <CALzJLG8nFBFy=-pjy-XBYb-y-F=grC5wjN35zTt9eUOT-612Eg@mail.gmail.com>
         <1480212960.18162.23.camel@edumazet-glaptop3.roam.corp.google.com>
         <20161128.154057.1355209532933900181.davem@davemloft.net>
         <CALzJLG8qjz7Qx8rWbthtJ1uJt2c8w_1gMeRkmB+SZ+xv2Eu3EQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        Linux Netdev List <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>
To: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:34242 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755318AbcK1W6p (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 17:58:45 -0500
Received: by mail-pg0-f67.google.com with SMTP id e9so14300460pgc.1
        for <netdev@vger.kernel.org>; Mon, 28 Nov 2016 14:58:44 -0800 (PST)
In-Reply-To: <CALzJLG8qjz7Qx8rWbthtJ1uJt2c8w_1gMeRkmB+SZ+xv2Eu3EQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-11-28 at 23:55 +0200, Saeed Mahameed wrote:

> I have nothing against this patch, I just wanted to point out that
> this patch is just fixing the symptom.


> We keep ignoring the root cause that dev_get_stats is called under a
> spin_lock which really ties our hands "us device drivers developers"
> and push us towards those fragile solutions like deferred work for
> caching statistics.

Well, we do not want to allow a driver to wait several ms to fetch
stats, or allowing the operation to fail is memory for the transaction
can not be allocated.

Otherwise, some monitoring tools could really have serious problems
under stress.

We really don't care of how often the 'not really hot counters' are
fetched from the NIC. I guess even once per second should be good
enough.

But these 4 counters (bytes/packets rx/tx), especially if they are
given by counters managed in the driver, should reflect the most current
value.
