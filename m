From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: Performance regression on kernels 3.10 and newer
Date: Thu, 14 Aug 2014 13:31:46 -0700
Message-ID: <53ED1CB2.7050006@intel.com>
References: <53ECFDAB.5010701@intel.com> <1408041962.6804.31.camel@edumazet-glaptop2.roam.corp.google.com> <53ED1516.6020801@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Rick Jones <rick.jones2@hp.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:52136 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754116AbaHNUbr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Aug 2014 16:31:47 -0400
In-Reply-To: <53ED1516.6020801@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/14/2014 12:59 PM, Rick Jones wrote:
> On 08/14/2014 11:46 AM, Eric Dumazet wrote:
> 
>> I believe you answered your own question : prequeue mode does not work
>> very well when one host has hundred of active TCP flows to one other.
>>
>> In real life, applications do not use prequeue, because nobody wants one
>> thread per flow.

My concern here is that netperf is a standard tool to use for testing
network performance, and the kernel default is to run with
tcp_low_latency disabled.  As such the prequeue is a part of the
standard path is it not?  If the prequeue isn't really useful anymore
should we consider pulling it out of the kernel, or disabling it by
making tcp_low_latency the default?

>> Each socket has its own dst now route cache was removed, but if your
>> netperf migrates cpu (and NUMA node), we do not detect the dst should be
>> re-created onto a different NUMA node.
> 
> Presumably, the -T $i,$j option in Alex's netperf command lines will
> have bound netperf and netserver to a specific CPU where they will have
> remained.
> 
> rick jones

Yes, my test was affinitized per CPU.  I was originally trying to test
some local vs remote NUMA performance numbers.  Also as I mentioned I
was using the ixgbe driver with 82599 and I had ATR enabled so the
receive flow was affinitized to the queue as well.  We shouldn't have
had any cross node chatter as a result of that.

Thanks,

Alex
