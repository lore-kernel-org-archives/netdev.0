From: Tom Herbert <therbert@google.com>
Subject: Re: Question on Lockless TX
Date: Wed, 16 Apr 2014 09:51:09 -0700
Message-ID: <CA+mtBx-m2zZfZ3AQOkv=4St2bWpipEEY0+O7kAJtReCa6ZkizA@mail.gmail.com>
References: <CAJzFV37OPJVVx3rO=L9RRZFn8NajiR1HZuZEZ8M3SepXTsMQ6A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Sharat Masetty <sharat04@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f174.google.com ([209.85.213.174]:39798 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754461AbaDPQvK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Apr 2014 12:51:10 -0400
Received: by mail-ig0-f174.google.com with SMTP id h18so1256166igc.7
        for <netdev@vger.kernel.org>; Wed, 16 Apr 2014 09:51:09 -0700 (PDT)
In-Reply-To: <CAJzFV37OPJVVx3rO=L9RRZFn8NajiR1HZuZEZ8M3SepXTsMQ6A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 15, 2014 at 9:29 PM, Sharat Masetty <sharat04@gmail.com> wrote:
> Can someone explain to me, why would a driver choose to implement
> Lockless TX? What are the advantages/disadvantages of choosing to do
> so?Any performance benefits? A reference to a sample driver
> implementation would be helpful to understand.
>
Locks in the TX path are needed provide mutual exclusion to the
underlying HW queue and other structures. Some drivers either don't
need any form of locking because their is no queue to protect (often
the case with virtual drivers like loopback and bonding), others might
provide their own locking at higher granularity or for other purposes.
Generally, taking fewer locks can reduce lock contention, atomic
operations, and cache line misses. If you grep for NETIF_F_LLTX under
drivers/net you can find examples of drivers that support this. Also,
please look at Documentation/networking/netdevices.txt.

Tom

> Thanks
> Sharat
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
