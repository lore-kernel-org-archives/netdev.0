From: "Xin, Xiaohui" <xiaohui.xin@intel.com>
Subject: RE: [RFC PATCH v8 00/16] Provide a zero-copy method on KVM
 virtio-net.
Date: Tue, 3 Aug 2010 16:48:08 +0800
Message-ID: <F2E9EB7348B8264F86B6AB8151CE2D791BAB307B7E@shsmsx502.ccr.corp.intel.com>
References: <1280402088-5849-1-git-send-email-xiaohui.xin@intel.com>
 <1280442682.9058.15.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"mst@redhat.com" <mst@redhat.com>, "mingo@elte.hu" <mingo@elte.hu>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"herbert@gondor.apana.org.au" <herbert@gondor.apana.org.au>,
	"jdike@linux.intel.com" <jdike@linux.intel.com>
To: Shirley Ma <mashirle@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:30962 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752171Ab0HCIsP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Aug 2010 04:48:15 -0400
In-Reply-To: <1280442682.9058.15.camel@localhost.localdomain>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: Shirley Ma [mailto:mashirle@us.ibm.com]
>Sent: Friday, July 30, 2010 6:31 AM
>To: Xin, Xiaohui
>Cc: netdev@vger.kernel.org; kvm@vger.kernel.org; linux-kernel@vger.kernel.org;
>mst@redhat.com; mingo@elte.hu; davem@davemloft.net; herbert@gondor.apana.org.au;
>jdike@linux.intel.com
>Subject: Re: [RFC PATCH v8 00/16] Provide a zero-copy method on KVM virtio-net.
>
>Hello Xiaohui,
>
>On Thu, 2010-07-29 at 19:14 +0800, xiaohui.xin@intel.com wrote:
>> The idea is simple, just to pin the guest VM user space and then
>> let host NIC driver has the chance to directly DMA to it.
>> The patches are based on vhost-net backend driver. We add a device
>> which provides proto_ops as sendmsg/recvmsg to vhost-net to
>> send/recv directly to/from the NIC driver. KVM guest who use the
>> vhost-net backend may bind any ethX interface in the host side to
>> get copyless data transfer thru guest virtio-net frontend.
>
>Since vhost-net already supports macvtap/tun backends, do you think
>whether it's better to implement zero copy in macvtap/tun than inducing
>a new media passthrough device here?
>
>> Our goal is to improve the bandwidth and reduce the CPU usage.
>> Exact performance data will be provided later.
>
>I did some vhost performance measurement over 10Gb ixgbe, and found that
>in order to get consistent BW results, netperf/netserver, qemu, vhost
>threads smp affinities are required.
>
>Looking forward to these results for small message size comparison. For
>large message size 10Gb ixgbe BW already reached by doing vhost smp
>affinity w/i offloading support, we will see how much CPU utilization it
>can be reduced.
>
>Please provide latency results as well. I did some experimental on
>macvtap zero copy sendmsg, what I have found that get_user_pages latency
>pretty high.
>
May you share me with your performance results (including BW and latency)on 
vhost-net and how you get them(your configuration and especially with the affinity 
settings)?

Thanks
Xiaohui

>Thanks
>Shirley
>
>
>

