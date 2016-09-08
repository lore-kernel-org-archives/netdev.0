From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3 net-next 1/1] net_sched: Introduce skbmod action
Date: Thu, 08 Sep 2016 09:11:17 -0700
Message-ID: <1473351077.15733.63.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1472386756-23085-1-git-send-email-jhs@emojatatu.com>
         <1472400467.14381.252.camel@edumazet-glaptop3.roam.corp.google.com>
         <b075631d-92cc-d016-3786-aaacb3d5c13a@mojatatu.com>
         <b117fac2-c73f-2d42-3843-52f9717224d9@mojatatu.com>
         <1472494817.14381.267.camel@edumazet-glaptop3.roam.corp.google.com>
         <2a6e36a6-f128-ba9d-4d69-90ff5383fb75@mojatatu.com>
         <68852282-b009-7b5b-6887-1630935b1913@mojatatu.com>
         <1472561089.14381.296.camel@edumazet-glaptop3.roam.corp.google.com>
         <a90c3d11-e1e9-3f58-5400-8b910d707351@mojatatu.com>
         <1473171919.10725.3.camel@edumazet-glaptop3.roam.corp.google.com>
         <6a0f8bfd-97d2-1e08-7ad7-b5791cb4312c@mojatatu.com>
         <1473350573.15733.61.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, daniel@iogearbox.net,
        xiyou.wangcong@gmail.com,
        John Fastabend <john.r.fastabend@intel.com>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:34213 "EHLO
        mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932650AbcIHQLU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Sep 2016 12:11:20 -0400
Received: by mail-pf0-f176.google.com with SMTP id p64so19675860pfb.1
        for <netdev@vger.kernel.org>; Thu, 08 Sep 2016 09:11:19 -0700 (PDT)
In-Reply-To: <1473350573.15733.61.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-09-08 at 09:02 -0700, Eric Dumazet wrote:
> On Thu, 2016-09-08 at 06:38 -0400, Jamal Hadi Salim wrote:
> > On 16-09-06 10:25 AM, Eric Dumazet wrote:
> > 
> > >
> > > Just use u16 in the array ?
> > >
> > > u16 tmpaddr[ETH_ALEN / 2]; /* ether_addr_copy() requirement */
> > >
> > > ether_addr_copy((u8 *)tmpaddr, eth_hdr(skb)->h_dest);
> > > ...
> > >
> > 
> > Ok - thanks Eric. BTW:
> > Nobody has answered my other question:
> > I can get stats to increment with:
> > bstats_update(&d->tcf_bstats, skb);
> > but not:
> > bstats_cpu_update(this_cpu_ptr(d->common.cpu_bstats), skb);
> 
> This simply works for me.
> 
> But maybe you read the stats at the wrong place ?
> 
> Pleas give us more details, thanks !

And double check the tcf_hash_create() call :

Last parameter is a boolean, and you must set it to true if you want per
cpu stats !
