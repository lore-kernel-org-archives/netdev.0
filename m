From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Quota in __qdisc_run() (was: qdisc: validate skb without
 holding lock)
Date: Tue, 07 Oct 2014 05:47:18 -0700
Message-ID: <1412686038.11091.111.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20141003.145647.1980640682969765484.davem@davemloft.net>
	 <1412373477.17245.5.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1412375467.17245.16.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20141003.153645.72976986956341944.davem@davemloft.net>
	 <1412379044.17245.26.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20141007093441.35ce3a02@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	therbert@google.com, hannes@stressinduktion.org, fw@strlen.de,
	dborkman@redhat.com, jhs@mojatatu.com, alexander.duyck@gmail.com,
	john.r.fastabend@intel.com, dave.taht@gmail.com, toke@toke.dk
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:34485 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753159AbaJGMrU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2014 08:47:20 -0400
Received: by mail-pa0-f49.google.com with SMTP id hz1so7100944pad.36
        for <netdev@vger.kernel.org>; Tue, 07 Oct 2014 05:47:19 -0700 (PDT)
In-Reply-To: <20141007093441.35ce3a02@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-10-07 at 09:34 +0200, Jesper Dangaard Brouer wrote:
> On Fri, 03 Oct 2014 16:30:44 -0700 Eric Dumazet <eric.dumazet@gmail.com> wrote:
> 
> > Another problem we need to address is the quota in __qdisc_run()
> > is no longer meaningfull, if each qdisc_restart() can pump many packets.
> 
> I fully agree. My earlier "magic" packet limit was covering/pampering
> over this issue.

Although quota was multiplied by 7 or 8 in worst case ?

> 
> > An idea would be to use the bstats (or cpu_qstats if applicable)
> 
> Please elaborate some more, as I don't completely follow (feel free to
> show with a patch ;-)).
> 

I was hoping John could finish the percpu stats before I do that.

Problem with q->bstats.packets is that TSO packets with 45 MSS add 45 to
this counter.

Using a time quota would be better, but : jiffies is too big, and
local_clock() might be too expensive.
