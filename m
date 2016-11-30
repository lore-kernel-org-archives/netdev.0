From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [WIP] net+mlx4: auto doorbell
Date: Wed, 30 Nov 2016 14:40:17 -0800
Message-ID: <1480545617.18162.212.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20140903165943.372b897b@redhat.com>
         <20161116234022.2bad179b@redhat.com>
         <1479342849.8455.233.camel@edumazet-glaptop3.roam.corp.google.com>
         <20161117091638.5fab8494@redhat.com>
         <1479388850.8455.240.camel@edumazet-glaptop3.roam.corp.google.com>
         <20161117144248.23500001@redhat.com>
         <1479392258.8455.249.camel@edumazet-glaptop3.roam.corp.google.com>
         <20161117155753.17b76f5a@redhat.com>
         <1479399679.8455.255.camel@edumazet-glaptop3.roam.corp.google.com>
         <20161117193021.580589ae@redhat.com>
         <1479408683.8455.273.camel@edumazet-glaptop3.roam.corp.google.com>
         <20161121170351.50a09ee1@redhat.com>
         <1479751857.8455.419.camel@edumazet-glaptop3.roam.corp.google.com>
         <1480402716.18162.124.camel@edumazet-glaptop3.roam.corp.google.com>
         <20161130123810.581ba21f@redhat.com>
         <1480521386.18162.189.camel@edumazet-glaptop3.roam.corp.google.com>
         <20161130201711.2f353a76@redhat.com>
         <1480534200.18162.203.camel@edumazet-glaptop3.roam.corp.google.com>
         <20161130233015.3de95356@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Rick Jones <rick.jones2@hpe.com>, netdev@vger.kernel.org,
        Saeed Mahameed <saeedm@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>,
        Achiad Shochat <achiad@mellanox.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:35724 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752856AbcK3W5t (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 17:57:49 -0500
Received: by mail-pg0-f65.google.com with SMTP id p66so2577741pga.2
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2016 14:57:49 -0800 (PST)
In-Reply-To: <20161130233015.3de95356@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-11-30 at 23:30 +0100, Jesper Dangaard Brouer wrote:
> On Wed, 30 Nov 2016 11:30:00 -0800
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
> 
> > On Wed, 2016-11-30 at 20:17 +0100, Jesper Dangaard Brouer wrote:
> > 
> > > Don't take is as critique Eric.  I was hoping your patch would have
> > > solved this issue of being sensitive to TX completion adjustments.  You
> > > usually have good solutions for difficult issues. I basically rejected
> > > Achiad's approach/patch because it was too sensitive to these kind of
> > > adjustments.  
> > 
> > Well, this patch can hurt latencies, because a doorbell can be delayed,
> > and softirqs can be delayed by many hundred of usec in some cases.
> > 
> > I would not enable this behavior by default.
> 
> What about another scheme, where dev_hard_start_xmit() can return an
> indication that driver choose not to flush (based on TX queue depth),
> and there by requesting stack to call flush at a later point.
> 
> Would that introduce less latency issues?


Again, how is it going to change anything when your netperf UDP sends
one packet at a time ?

qdisc gets one packet , dequeue it immediately.

No pressure. -> doorbell will be sent as before.

Some TX producers do not even use a qdisc to begin with.

Please think of a solution that does not involve qdisc layer at all.
