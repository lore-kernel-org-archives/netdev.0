From: "Alexander Duyck" <alexander.duyck@gmail.com>
Subject: Re: [PATCH 3/3] pkt_sched: restore multiqueue prio scheduler
Date: Sat, 23 Aug 2008 09:31:06 -0700
Message-ID: <5f2db9d90808230931n453a3b75q84153dd8c18bcfc2@mail.gmail.com>
References: <1219415417.4672.79.camel@localhost>
	 <20080822221913.GA2981@ami.dom.local>
	 <20080822.173348.232018958.davem@davemloft.net>
	 <20080823084715.GA2515@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>, hadi@cyberus.ca,
	jeffrey.t.kirsher@intel.com, jeff@garzik.org,
	netdev@vger.kernel.org, alexander.h.duyck@intel.com
To: "Jarek Poplawski" <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.30]:38651 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751597AbYHWQbI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Aug 2008 12:31:08 -0400
Received: by yx-out-2324.google.com with SMTP id 8so539329yxm.1
        for <netdev@vger.kernel.org>; Sat, 23 Aug 2008 09:31:07 -0700 (PDT)
In-Reply-To: <20080823084715.GA2515@ami.dom.local>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Aug 23, 2008 at 1:47 AM, Jarek Poplawski <jarkao2@gmail.com> wrote:
> On Fri, Aug 22, 2008 at 05:33:48PM -0700, David Miller wrote:
> ...
>> If we want queue selection in the packet scheduler, let's implement
>> it, but let's do so properly using classifiers and TC actions or a
>> ematch modules that can select the queue.
>>
>> Then people can implement whatever policy they want, in completely
>> generic ways, and the kernel simply doesn't care.
>>
>> The way this code worked was completely special purpose and ignored
>> the host of facilities and infrastructure we have for doing things
>> like this.
>
> Alas I can't get your point here. prio is sched + classifier 2 in 1,
> and if a small change in this is enough for somebody who really uses
> this, and there seem to be noone interested in doing this better or
> harmed with this, why bother with actions or other classifiers? Maybe
> this prio method is less generic, but it's quite simple and there is
> some infrastructure around this.
>
> Jarek P.

Actually in this new multiple tx queue kernel this qdisc could serve a
very specific but needed purpose which just became apparent to me.
This qdisc resolves one very specific issue, head-of-line blocking if
one of the hardware queues is full.  What if I reversed things a bit
in prio_classify so that skb->queue_mapping determined the band
instead of the other way around in the case of the multiqueue option
being enabled?  I would think that in this configuration the qdisc
would prove to be pretty useful for purposes other than QOS since it
would allow a classful qdisc per transmit queue instead of per device.

I could then create a select_queue for the device that returns 0 when
in DCB/EEDC mode for our drivers, implement the tc action to set the
queue mapping, and have essentially the same result as I had before.

Thanks,

Alex
