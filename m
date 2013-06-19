From: Rick Jones <rick.jones2@hp.com>
Subject: Re: qlen check in tun.c
Date: Wed, 19 Jun 2013 14:37:11 -0700
Message-ID: <51C22487.4080505@hp.com>
References: <CAPshTCgdb9FzKHzxkpDpowZjzqBv5yM_rBpcT88YmYBSojN8Tw@mail.gmail.com> <51C12592.6050503@redhat.com> <CAPshTCj+2wx=LhHujMqiZc1ptvGbcn+V7P9aAhBELHf6cbL+jg@mail.gmail.com> <51C20B3E.1050708@hp.com> <CAPshTCg=v0Sy-bDg=RrGT=JGKVLTgCj3rZwKG_EK9p5C2sJOmA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jason Wang <jasowang@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Michael S. Tsirkin" <mst@redhat.com>
To: Jerry Chu <hkchu@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0026.austin.hp.com ([15.216.28.33]:37272 "EHLO
	g1t0026.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934929Ab3FSVhM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jun 2013 17:37:12 -0400
In-Reply-To: <CAPshTCg=v0Sy-bDg=RrGT=JGKVLTgCj3rZwKG_EK9p5C2sJOmA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/19/2013 01:42 PM, Jerry Chu wrote:
> On Wed, Jun 19, 2013 at 12:49 PM, Rick Jones <rick.jones2@hp.com> wrote:
>> Assuming this single-stream is a netperf test, what happens when you cap the
>> socket buffers to 724000 bytes?  Put another way, is this simply a situation
>> where the autotuning of the socket buffers/window is taking a connection
>> somewhere it shouldn't go?
>
> You have a good point - for single netperf streaming the TCP window seems to
> grow much larger than necessary. Manually capping socket buffer seems to make
> the problem go away without hurting throughput - but only to some extent.
> Unfortunately manual setting is undesirable, and the autotuning code
> is difficult to "tune".
>

...

>> Just what is the bandwidthXdelay product through the openvswitch?
>
> Unlike the traditional NIC, for tuntap it'd be CPU b/w times scheduling delay.
> Both can have a large variance. I haven't figured out how to right size the
> qlen in this scenario.

In perhaps overly broad, handwaving terms, doesn't wireless have a 
similar problem with highly variable latency/delay?

In theory, if your max scheduling delay is 10 milliseconds, your still 
not large enough 8192 entry queue should still get you 1 GB/s assuming 
that it is >> 1 GB/s between scheduling delays.   Is there really an 
expectation/requirement to get better than that or have even larger 
scheduling delays?  The existence of 40 and 100 GbE (even bonded 10GbE) 
notwithstanding, once one is talking about 1 GB/s one is looking more at 
SR-IOV I would think, not going through an Openvswitch.

Do you actually still see single-stream drops at 8192?  That should be 
something like 11 MB of queuing - I don't think I've seen tcp_[wr]mem go 
above 6 MB thusfar...

rick
