From: Paolo Bonzini <pbonzini@redhat.com>
Subject: Re: [PATCH] vhost: support upto 509 memory regions
Date: Tue, 17 Feb 2015 18:09:06 +0100
Message-ID: <54E375B2.8090101@redhat.com>
References: <1423842599-5174-1-git-send-email-imammedo@redhat.com>	<20150217090242.GA20254@redhat.com>	<54E31F24.1060705@redhat.com>	<20150217123212.GA6362@redhat.com>	<54E33E09.5090603@redhat.com>	<20150217132931.GB6362@redhat.com> <20150217160240.1085e2f7@nial.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org, kvm@vger.kernel.org,
	netdev@vger.kernel.org
To: Igor Mammedov <imammedo@redhat.com>,
	"Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150217160240.1085e2f7@nial.brq.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 17/02/2015 16:02, Igor Mammedov wrote:
>> > 
>> > Not if there are about 6 regions, I think.
> When memslots where increased to 509 and look up of them was replaced on
> binary search results were on par with linear search for a default 13 memslots VM.
> 
> Adding LRU

You mean MRU. :)

> cache helped to shave ~40% of cycles for sequential lookup workloads.

It's a bit different for vhost because you can have up to four "things"
being looked up at the same time:

- the s/g list that will end up in the skb

- the avail/used ring

- the virtio buffers

- the virtio indirect buffers

So you probably need multiple MRU caches.  But yes, MRU can help a lot.

Paolo
