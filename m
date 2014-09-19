From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC net-next PATCH V3 0/2] qdisc bulk dequeuing and utilizing
 delayed tailptr updates
Date: Fri, 19 Sep 2014 15:52:55 -0700
Message-ID: <1411167175.26859.55.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140919204706.3231.59125.stgit@dragon>
	 <1411160360.26859.31.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140919233108.5bd43ccc@redhat.com>
	 <1411163126.26859.40.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAHA+R7NHRaLtzBJd_Sc6_aNLMs=iGHTBK8j9Bq0ntCDg-meLZg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
	netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Florian Westphal <fw@strlen.de>,
	Daniel Borkmann <dborkman@redhat.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Dave Taht <dave.taht@gmail.com>, toke@toke.dk
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:60477 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757977AbaISWw6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Sep 2014 18:52:58 -0400
Received: by mail-pa0-f50.google.com with SMTP id fa1so961587pad.9
        for <netdev@vger.kernel.org>; Fri, 19 Sep 2014 15:52:57 -0700 (PDT)
In-Reply-To: <CAHA+R7NHRaLtzBJd_Sc6_aNLMs=iGHTBK8j9Bq0ntCDg-meLZg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-09-19 at 15:39 -0700, Cong Wang wrote:

> Then why commits like this one?
> 
> commit 7070ce0a6419a118842298bc967061ad6cea40db
> Author: Alexander Duyck <alexander.h.duyck@intel.com>
> Date:   Sat Sep 28 06:00:37 2013 +0000
> 
>     i40e: Add support for Tx byte queue limits
> 
>     Implement BQL (byte queue limit) support in i40e.
> 

Read again my full mail, don't jump into conclusions in the middle of
it.


> 
> >
> > If a device driver do nothing about BQL, byte_queue_limits/limit will be
> > zero by default.

See here ? Its all explained. If a device driver do not implement BQL,
limit will be zero, and bulk dequeue will _automatically_ be disabled.

BQL has no 'cost' if a driver does not use it.

Its basically fields which will never be updated.

(cf in struct netdev_queue :
			struct dql      dql;
)

> 

> Also note that for some virtual device, BQL may make no sense at all,
> at least veth doesn't even use a TX queue (I know it has tx-0 mostly for
> qdisc). Perhaps all NETIF_F_LLTX ones?

Lets focus on the normal cases, where virtual devices do not have any
qdisc.

We are talking here of _qdisc_ bulk dequeue, right ?
