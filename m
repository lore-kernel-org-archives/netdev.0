From: Dave Taht <dave.taht@gmail.com>
Subject: Re: [RFC net-next PATCH V3 0/2] qdisc bulk dequeuing and utilizing
 delayed tailptr updates
Date: Sat, 20 Sep 2014 00:28:52 +0300
Message-ID: <CAA93jw7mSjHZTi+MASzAvefNVGR7YEY=O3BHoP7gjkpG3AXG5A@mail.gmail.com>
References: <20140919204706.3231.59125.stgit@dragon>
	<1411160360.26859.31.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Florian Westphal <fw@strlen.de>,
	Daniel Borkmann <dborkman@redhat.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	=?UTF-8?B?VG9rZSBIw7hpbGFuZC1Kw7hyZ2Vuc2Vu?= <toke@toke.dk>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f49.google.com ([209.85.219.49]:65321 "EHLO
	mail-oa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757804AbaISV2x convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Sep 2014 17:28:53 -0400
Received: by mail-oa0-f49.google.com with SMTP id jd19so2206935oac.36
        for <netdev@vger.kernel.org>; Fri, 19 Sep 2014 14:28:52 -0700 (PDT)
In-Reply-To: <1411160360.26859.31.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 19, 2014 at 11:59 PM, Eric Dumazet <eric.dumazet@gmail.com>=
 wrote:
> On Fri, 2014-09-19 at 22:49 +0200, Jesper Dangaard Brouer wrote:
>> This patchset uses DaveM's recent API changes to dev_hard_start_xmit=
(),
>> from the qdisc layer, to implement dequeue bulking.
>>
>> RFC V3: Keeping the ball rolling.
>>
>> This patchset should now use BQL correctly.  I've done lots of testi=
ng
>> for Head-of-Line blocking issues that can occur due to requeue of a
>> SKB bulk list.  I've not been able to provoke any HoL blocking
>> situation, simply because BQL is doing such a good job, thus I'm
>> unable to "overshoot" HW/BQL limits with more than a single packet.
>>
>> This patch chooses a very conservative approach, as by default only
>> allowing dequeue of one extra packet, besides the normal dequeue.
>>
>> Open questions:
>>
>> - How do we expose tuning to userspace?
>>   Patch adds /proc/sys/net/core/qdisc_bulk_dequeue_limit but I don't=
 like it...
>>   Per device tunable?
>>
>
> bql is using /sys, of course ;)
>
> # grep . /sys/class/net/eth1/queues/tx-0/byte_queue_limits/*
> /sys/class/net/eth1/queues/tx-0/byte_queue_limits/hold_time:1000
> /sys/class/net/eth1/queues/tx-0/byte_queue_limits/inflight:0
> /sys/class/net/eth1/queues/tx-0/byte_queue_limits/limit:113314
> /sys/class/net/eth1/queues/tx-0/byte_queue_limits/limit_max:187904819=
2
> /sys/class/net/eth1/queues/tx-0/byte_queue_limits/limit_min:0
>
> Maybe you could simply reuse byte_queue_limits/limit, I am not sure w=
e
> need a specific tunable.
>
>
>> - Can/should we limit dequeue bulking to devices supporting BQL?
>>
>
> Yes please. This will be an incentive to get BQL on drivers.

While I am +100 on getting more BQL'd drivers out there...

https://www.bufferbloat.net/projects/bloat/wiki/BQL_enabled_drivers

=2E.. It was my hope that some of this bulk dequeue work would apply to
wifi packet aggregation one day....

>
>
>



--=20
Dave T=C3=A4ht

https://www.bufferbloat.net/projects/make-wifi-fast
