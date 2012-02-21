From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH 2/2] vhost-net: add a spin_threshold parameter
Date: Tue, 21 Feb 2012 14:38:13 +0800
Message-ID: <4F433BD5.1070400@redhat.com>
References: <1329519726-25763-1-git-send-email-aliguori@us.ibm.com>  <1329519726-25763-3-git-send-email-aliguori@us.ibm.com>  <20120219145100.GB16620@redhat.com>  <1329788131.13141.14.camel@localhost.localdomain>  <4F432CDC.4090107@redhat.com> <1329805716.24119.3.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	Anthony Liguori <aliguori@us.ibm.com>, netdev@vger.kernel.org,
	Tom Lendacky <toml@us.ibm.com>,
	Cristian Viana <vianac@br.ibm.com>
To: Shirley Ma <mashirle@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:29490 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750804Ab2BUGiT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Feb 2012 01:38:19 -0500
In-Reply-To: <1329805716.24119.3.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/21/2012 02:28 PM, Shirley Ma wrote:
> On Tue, 2012-02-21 at 13:34 +0800, Jason Wang wrote:
>> On 02/21/2012 09:35 AM, Shirley Ma wrote:
>>> We tried similar approach before by using a minimum timer for
>> handle_tx
>>> to stay in the loop to accumulate more packets before enabling the
>> guest
>>> notification. It did have better TCP_RRs, UDP_RRs results. However,
>> we
>>> think this is just a debug patch. We really need to understand why
>>> handle_tx can't see more packets to process for multiple instances
>>> request/response type of workload first. Spinning in this loop is
>> not a
>>> good solution.
>> Spinning help for the latency, but looks like we need some adaptive
>> method to adjust the threshold dynamically such as monitor the
>> minimum
>> time gap between two packets. For throughput, if we can improve the
>> batching of small packets we can improve it. I've tired to use event
>> index to delay the tx kick until a specified number of packets were
>> batched in the virtqueue. Test shows improvement of throughput in
>> small
>> packets as the number of #exit were reduced greatly ( the
>> packets/#exit
>> and cpu utilization were increased), but it damages the performance
>> of
>> other. This is only for debug, but it confirms that there's something
>> we
>> need to improve the batching.
> Our test case was 60 instances 256/256 bytes tcp_rrs or udp_rrs. In
> theory there should be multiple packets in the queue by the time vhost
> gets notified, but from debugging output, there was only a few or even
> one packet in the queue. So the questions here why the time gap between
> two packets is that big?
>
> Shirley

Not sure whether it's related but did you try to disable the nagle 
algorithm during the test?
