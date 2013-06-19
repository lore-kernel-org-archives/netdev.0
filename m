From: Rick Jones <rick.jones2@hp.com>
Subject: Re: qlen check in tun.c
Date: Wed, 19 Jun 2013 12:49:18 -0700
Message-ID: <51C20B3E.1050708@hp.com>
References: <CAPshTCgdb9FzKHzxkpDpowZjzqBv5yM_rBpcT88YmYBSojN8Tw@mail.gmail.com> <51C12592.6050503@redhat.com> <CAPshTCj+2wx=LhHujMqiZc1ptvGbcn+V7P9aAhBELHf6cbL+jg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jason Wang <jasowang@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Michael S. Tsirkin" <mst@redhat.com>
To: Jerry Chu <hkchu@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g6t0187.atlanta.hp.com ([15.193.32.64]:3800 "EHLO
	g6t0187.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756805Ab3FST5y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jun 2013 15:57:54 -0400
In-Reply-To: <CAPshTCj+2wx=LhHujMqiZc1ptvGbcn+V7P9aAhBELHf6cbL+jg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/19/2013 12:39 PM, Jerry Chu wrote:
> Hi Jason,
>
> On Tue, Jun 18, 2013 at 8:29 PM, Jason Wang <jasowang@redhat.com> wrote:
>> On 06/19/2013 10:31 AM, Jerry Chu wrote:
>>> In tun_net_xmit() the max qlen is computed as
>>> dev->tx_queue_len / tun->numqueues. For multi-queue configuration the
>>> latter may be way too small, forcing one to adjust txqueuelen based
>>> on number of queues created. (Well the default txqueuelen of
>>> 500/TUN_READQ_SIZE already seems too small even for single queue.)
>>
>> Hi Jerry:
>>
>> Do you have some test result of this? Anyway, tun allows userspace to
>> adjust this value based on its requirement.
>
> Sure, but the default size of 500 is just way too small. queue overflows even
> with a simple single-stream throughput test through Openvswitch due to CPU
> scheduler anomaly. On our loaded multi-stream test even 8192 can't prevent
> queue overflow. But then with 8192 we'll be deep into the "buffer
> bloat" territory.

Assuming this single-stream is a netperf test, what happens when you cap 
the socket buffers to 724000 bytes?  Put another way, is this simply a 
situation where the autotuning of the socket buffers/window is taking a 
connection somewhere it shouldn't go?

> We haven't figured out an optimal strategy for thruput vs latency, but
> suffice to say 500 is too small.

Just what is the bandwidthXdelay product through the openvswitch?

happy benchmarking,

rick
