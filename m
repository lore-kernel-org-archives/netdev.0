From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH 0/4] inet: add second hash table
Date: Wed, 30 May 2012 14:41:02 +0200
Message-ID: <1338381662.2760.172.camel@edumazet-glaptop>
References: <1338363410-6562-1-git-send-email-alex.mihai.c@gmail.com>
	 <1338364640.2760.96.camel@edumazet-glaptop>
	 <CAEnQRZD3o_+fRnnbd74VeFuNvjAVVyq-rE241J96iRXWFDAEPQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Alexandru Copot <alex.mihai.c@gmail.com>, davem@davemloft.net,
	gerrit@erg.abdn.ac.uk, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org,
	Lucian Grijincu <lucian.grijincu@gmail.com>
To: Daniel Baluta <dbaluta@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:55085 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753652Ab2E3MlI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 May 2012 08:41:08 -0400
Received: by bkcji2 with SMTP id ji2so4059473bkc.19
        for <netdev@vger.kernel.org>; Wed, 30 May 2012 05:41:07 -0700 (PDT)
In-Reply-To: <CAEnQRZD3o_+fRnnbd74VeFuNvjAVVyq-rE241J96iRXWFDAEPQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-05-30 at 15:32 +0300, Daniel Baluta wrote:


> Hi Eric,
> 
> Usually our tests use a huge number of virtual interfaces.
> Using this patch we get a massive improvement when there are many sockets
> bound to the same port, but different addresses for both bind() and
> listen() system calls (both call inet_csk_get_port).
> 	
> We provided some data points in the fourth patch:
> 
> For 16.000 interfaces each with a distinct IPv4 address, doing bind
> and then listen we get:
> 

> 
> If I understood it correctly, a similar patch was introduced
> for UDP some time ago. [2]
> 
> thanks,
> Daniel.
> 
> [1] http://ixlabs.cs.pub.ro/gitweb/?p=port-allocation.git;a=tree;f=testbind;h=687e4452101e13cb5995b43c1351d76786d98fdd;hb=HEAD
> [2] http://www.spinics.net/lists/netdev/msg112056.html


UDP case was a bit different, since production machine could really have
thousand of UDP flows for tunnel terminations.

But for TCP, unless your very specific needs I don't see the real need
to review 400 lines of patches ?

Nobody but you ever complained of listen() being performance critical
with 16.000 IP on a machime...
