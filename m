From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [RFC] [PATCH 0/3] ioat: DMA engine support
Date: Wed, 23 Nov 2005 17:06:42 -0500
Message-ID: <4384E7F2.2030508@pobox.com>
References: <Pine.LNX.4.44.0511231143380.32487-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	john.ronciak@intel.com, christopher.leech@intel.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932565AbVKWWGr@vger.kernel.org>
To: Andrew Grover <andrew.grover@intel.com>
In-Reply-To: <Pine.LNX.4.44.0511231143380.32487-100000@isotope.jf.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Grover wrote:
> As presented in our talk at this year's OLS, the Bensley platform, which 
> will be out in early 2006, will have an asyncronous DMA engine. It can be 
> used to offload copies from the CPU, such as the kernel copies of received 
> packets into the user buffer.

IOAT is super-neat stuff.

In addition to helping speed up network RX, I would like to see how 
possible it is to experiment with IOAT uses outside of networking. 
Sample ideas:  VM page pre-zeroing.  ATA PIO data xfers (async copy to 
static buffer, to dramatically shorten length of kmap+irqsave time). 
Extremely large memcpy() calls.

Additionally, current IOAT is memory->memory.  I would love to be able 
to convince Intel to add transforms and checksums, to enable offload of 
memory->transform->memory and memory->checksum->result operations like 
sha-{1,256} hashing[1], crc32*, aes crypto, and other highly common 
operations.  All of that could be made async.

	Jeff
