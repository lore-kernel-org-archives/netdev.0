From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Using HTB over MultiQ
Date: Thu, 07 Nov 2013 06:20:21 -0800
Message-ID: <1383834021.9412.61.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAEzD07+Haf-Kg52H7GsxC5XiQn2KXozHbxgL4Lvn0grhFXVFmA@mail.gmail.com>
	 <1383833480.9412.58.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Anton 'EvilMan' Danilov <littlesmilingcloud@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:60191 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750996Ab3KGOUX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Nov 2013 09:20:23 -0500
Received: by mail-pa0-f48.google.com with SMTP id kq14so666430pab.21
        for <netdev@vger.kernel.org>; Thu, 07 Nov 2013 06:20:23 -0800 (PST)
In-Reply-To: <1383833480.9412.58.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-11-07 at 06:11 -0800, Eric Dumazet wrote:
> On Thu, 2013-11-07 at 17:12 +0400, Anton 'EvilMan' Danilov wrote:
> > Hello.
> > 
> > I'm experimenting with high performance linux router with 10G NICs.
> > On high traffic rates the performance are limited by the lock of root
> > queue discipline. For avoid impact of locking i've decided to build
> > QoS scheme over the multiq qdisc.
> > 

Oh well, this is a router.

So I think you need to change the device queue selection so that it only
depends on your filters / htb classes.

Otherwise flows for a particular 'customer' might be spread on the 8
queues, so the rate could be 8 * 1Mbit, instead of 1Mbit.
