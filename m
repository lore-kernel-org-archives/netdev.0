From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [RFC] [PATCH 0/3] ioat: DMA engine support
Date: Wed, 23 Nov 2005 18:02:56 -0500
Message-ID: <4384F520.3060502@pobox.com>
References: <Pine.LNX.4.44.0511231143380.32487-100000@isotope.jf.intel.com> <4384E7F2.2030508@pobox.com> <20051123223007.GA5921@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Grover <andrew.grover@intel.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, john.ronciak@intel.com,
	christopher.leech@intel.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1030485AbVKWXDG@vger.kernel.org>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <20051123223007.GA5921@wotan.suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andi Kleen wrote:
> Longer term the right way to handle this would be likely to use
> POSIX AIO on sockets. With that interface it would be easier
> to keep long queues of data in flight, which would be best for
> the DMA engine.

Agreed.

For my own userland projects, I'm starting to feel the need for network 
AIO, since it is more natural:  the hardware operations themselves are 
asynchronous.


>>In addition to helping speed up network RX, I would like to see how 
>>possible it is to experiment with IOAT uses outside of networking. 
>>Sample ideas:  VM page pre-zeroing.  ATA PIO data xfers (async copy to 
>>static buffer, to dramatically shorten length of kmap+irqsave time). 
>>Extremely large memcpy() calls.
> 
> 
> Another proposal was swiotlb.

That's an interesting thought.


> But it's not clear it's a good idea: a lot of these applications prefer to 
> have the target in cache. And IOAT will force it out of cache.
> 
> 
>>Additionally, current IOAT is memory->memory.  I would love to be able 
>>to convince Intel to add transforms and checksums, to enable offload of 
>>memory->transform->memory and memory->checksum->result operations like 
>>sha-{1,256} hashing[1], crc32*, aes crypto, and other highly common 
>>operations.  All of that could be made async.
> 
> 
> I remember the registers in the Amiga Blitter for this and I'm
> still scared... Maybe it's better to keep it simple.

We're talking about CISC here!  ;-) ;-)

[note: I'm the type of person who would stuff the kernel + glibc onto an 
FPGA, if I could]

I would love to see Intel, AMD, VIA (others?) compete by adding selected 
transforms/checksums/hashs to their chips, though this method.  Just 
provide a method to enumerate what transforms are supported on <this> 
chip...

	Jeff
