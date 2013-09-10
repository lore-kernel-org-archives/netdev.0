From: Jason Wang <jasowang@redhat.com>
Subject: Re: TSQ accounting skb->truesize degrades throughput for large packets
Date: Tue, 10 Sep 2013 15:45:47 +0800
Message-ID: <522ECE2B.7020409@redhat.com>
References: <20130906101635.GI14104@zion.uk.xensource.com>   <1378472268.31445.15.camel@edumazet-glaptop> <522A049A.7000105@citrix.com>  <1378486604.31445.34.camel@edumazet-glaptop> <522D9466.6020205@redhat.com> <1378734444.26319.28.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Zoltan Kiss <zoltan.kiss@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>,
	Jonathan Davies <Jonathan.Davies@eu.citrix.com>,
	Ian Campbell <ian.campbell@citrix.com>, netdev@vger.kernel.org,
	xen-devel@lists.xenproject.org,
	"Michael S. Tsirkin" <mst@redhat.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:63441 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753719Ab3IJHqM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Sep 2013 03:46:12 -0400
In-Reply-To: <1378734444.26319.28.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/09/2013 09:47 PM, Eric Dumazet wrote:
> On Mon, 2013-09-09 at 17:27 +0800, Jason Wang wrote:
>
>> Virtio-net orphan the skb in .ndo_start_xmit() so TSQ can not throttle
>> packets in device accurately, and it also can't do BQL. Does this means
>> TSQ should be disabled for virtio-net?
>>
> If skb are orphaned, there is no way TSQ can work at all.

For example, virtio-net will stop the tx queue when it finds the tx
queue may full and enable the queue when some packets were sent. In this
case, tsq works and throttles the total bytes queued in qdisc. This
usually happen during heavy network load such as two sessions of netperf.
>
> It is already disabled, so why do you want to disable it ?
>
>

We notice a regression, and bisect shows it was introduced by TSQ.
