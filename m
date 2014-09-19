From: Cong Wang <cwang@twopensource.com>
Subject: Re: [RFC net-next PATCH V3 0/2] qdisc bulk dequeuing and utilizing
 delayed tailptr updates
Date: Fri, 19 Sep 2014 15:39:27 -0700
Message-ID: <CAHA+R7NHRaLtzBJd_Sc6_aNLMs=iGHTBK8j9Bq0ntCDg-meLZg@mail.gmail.com>
References: <20140919204706.3231.59125.stgit@dragon>
	<1411160360.26859.31.camel@edumazet-glaptop2.roam.corp.google.com>
	<20140919233108.5bd43ccc@redhat.com>
	<1411163126.26859.40.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
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
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f175.google.com ([209.85.217.175]:46525 "EHLO
	mail-lb0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758069AbaISWj2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Sep 2014 18:39:28 -0400
Received: by mail-lb0-f175.google.com with SMTP id n15so3938973lbi.20
        for <netdev@vger.kernel.org>; Fri, 19 Sep 2014 15:39:27 -0700 (PDT)
In-Reply-To: <1411163126.26859.40.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 19, 2014 at 2:45 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Fri, 2014-09-19 at 23:31 +0200, Jesper Dangaard Brouer wrote:
>
>> How can I test if the dev supports BQL?
>
>
> CONFIG_BQL should be enough.

Then why commits like this one?

commit 7070ce0a6419a118842298bc967061ad6cea40db
Author: Alexander Duyck <alexander.h.duyck@intel.com>
Date:   Sat Sep 28 06:00:37 2013 +0000

    i40e: Add support for Tx byte queue limits

    Implement BQL (byte queue limit) support in i40e.


>
> If a device driver do nothing about BQL, byte_queue_limits/limit will be
> zero by default.

Also note that for some virtual device, BQL may make no sense at all,
at least veth doesn't even use a TX queue (I know it has tx-0 mostly for
qdisc). Perhaps all NETIF_F_LLTX ones?
