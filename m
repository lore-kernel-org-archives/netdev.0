From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [net-next PATCH V5] qdisc: bulk dequeue support for qdiscs with
 TCQ_F_ONETXQUEUE
Date: Wed, 01 Oct 2014 09:17:39 -0400
Message-ID: <542BFEF3.7020302@mojatatu.com>
References: <20140930085114.24043.81310.stgit@dragon>	<542A8EF9.10403@mojatatu.com> <20140930.142038.235338672810639160.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, netdev@vger.kernel.org, therbert@google.com,
	eric.dumazet@gmail.com, hannes@stressinduktion.org, fw@strlen.de,
	dborkman@redhat.com, alexander.duyck@gmail.com,
	john.r.fastabend@intel.com, dave.taht@gmail.com, toke@toke.dk
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f179.google.com ([209.85.213.179]:40660 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751053AbaJANRr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2014 09:17:47 -0400
Received: by mail-ig0-f179.google.com with SMTP id h18so277317igc.12
        for <netdev@vger.kernel.org>; Wed, 01 Oct 2014 06:17:46 -0700 (PDT)
In-Reply-To: <20140930.142038.235338672810639160.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/30/14 14:20, David Miller wrote:
> From: Jamal Hadi Salim <jhs@mojatatu.com>
> Date: Tue, 30 Sep 2014 07:07:37 -0400
>
>> Note, there are benefits as you have shown - but i would not
>> consider those to be standard use cases (actully one which would
>> have shown clear win is the VM thing Rusty was after).
>
> I completely disagree, you will see at least decreased cpu utilization
> for a very common case, bulk single stream transfers.
>


So lets say the common use case is:
= modern day cpu (pick some random cpu)
= 1-10 Gbps ethernet (not 100mbps)
= 1-24 tcp or udp bulk (you said one, Jesper had 24 which sounds better)

Run with test cases:
a) unchanged (no bulking code added at all)
vs
b) bulking code added and used
vs
c) bulking code added and *not* used

Jesper's results are comparing #b and #c.

And if #b + #c are slightly worse or equal then we have a win;->

Again, I do believe things like traffic generators or the VM io
or something like tuntap that crosses user space will have a clear
benefit (but are those common use cases?).

cheers,
jamal
