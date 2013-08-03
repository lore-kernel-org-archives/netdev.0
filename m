From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: locating the 'tc actions' hook
Date: Sat, 03 Aug 2013 07:47:27 -0400
Message-ID: <51FCEDCF.8010107@mojatatu.com>
References: <51F97F4E.5070102@gmail.com> <51FA493C.8080207@mojatatu.com> <51FAECBF.3030704@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.fastabend@gmail.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Tom Herbert <therbert@google.com>,
	netdev <netdev@vger.kernel.org>
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f178.google.com ([209.85.215.178]:43329 "EHLO
	mail-ea0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751531Ab3HCLrc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Aug 2013 07:47:32 -0400
Received: by mail-ea0-f178.google.com with SMTP id a15so748013eae.23
        for <netdev@vger.kernel.org>; Sat, 03 Aug 2013 04:47:31 -0700 (PDT)
In-Reply-To: <51FAECBF.3030704@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13-08-01 07:18 PM, John Fastabend wrote:

[..]

> The first being directly related to the previous per queue rate limiter
> patch. With rate limiters per queue on a multiqueue device using mq or
> mqprio I need some mechanism to steer packets to queues. One way to do
> this is to use mqprio and create a 'tc' with a single queue in it.
> And then use iptables or netprio_cgroup to steer packets. Another way
> to do this would be to use 'skbedit queue_mapping' to set the queue from
> 'tc' but unfortunately with the existing flows the queue has already
> been selected by the time the classifiers are called.

I am assuming the skb (mark) will be tagged with a proper meaningful
tag maybe by the driver. Such a tag can be used later up-stack.

>Calling into the
> classifier chain before picking the qdisc would fix this. For flow based
> QOS with multiqueue devices this type of functionality would be useful.
>

 From your description this seems to be ingress side; so we should be
able to use that tag if you set it.


> The second thought that I've been piecing together would be to populate
> the rxhash (or maybe some other field) using the hardware flow
> classifier in some meaningful way for the ingress qdisc.


The rxhash would be useful for further classification or avoiding
further classification.

> Some of the
> existing Intel NICs can do this and I believe other vendors have similar
> capabilities. Although currently with the qdisc lock running around the
> ingress qdisc the multiqueue devices take a perf hit just by
> instantiating the ingress qdisc which really is only using the lock to
> guard some stats and keep the classifier/action chains sane.
>

Instantiating any qdisc is not a problem. You do it once and are done.
There are penalties with using qdiscs in terms of locking.
The locks penalties really have to do with the design of the netdev
not qdiscs i.e queues are centered around netdevs and netdevs
are shared across  processors.


> If you have some good examples it would be great to see them and drop
> them in my testbed. Go ahead and send them to me offlist if you can.
>

will do.

cheers,
jamal


> .John
>
