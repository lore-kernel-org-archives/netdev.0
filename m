From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: Optimizing instruction-cache, more packets at each stage
Date: Mon, 18 Jan 2016 12:54:20 +0100
Message-ID: <20160118125420.0375ffda@redhat.com>
References: <20160115142223.1e92be75@redhat.com>
	<063D6719AE5E284EB5DD2968C1650D6D1CCC6613@AcuExch.aculab.com>
	<20160115150025.13a5db04@redhat.com>
	<56990473.9090300@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Laight <David.Laight@ACULAB.COM>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Daniel Borkmann <borkmann@iogearbox.net>,
	Marek Majkowski <marek@cloudflare.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Florian Westphal <fw@strlen.de>,
	Paolo Abeni <pabeni@redhat.com>,
	John Fastabend <john.r.fastabend@intel.com>, brouer@redhat.com
To: Felix Fietkau <nbd@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46338 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754626AbcARLy2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Jan 2016 06:54:28 -0500
In-Reply-To: <56990473.9090300@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Fri, 15 Jan 2016 15:38:43 +0100 Felix Fietkau <nbd@openwrt.org> wrote:
> On 2016-01-15 15:00, Jesper Dangaard Brouer wrote:
[...]
> > 
> > The icache is still quite small 32Kb on modern server processors.  I
> > don't know if smaller embedded processors also have icache and how
> > large they are.  I speculate this approach would also be a benefit for
> > them (if they have icache).
>
> All of the router devices that I work with have icache. Typical sizes
> are 32 or 64 KiB. FWIW, I'm really looking forward to having such
> optimizations in the network stack ;)

That is very interesting. These kind of icache optimization will then
likely benefit lower-end devices more than high end Intel CPUs :-)

AFAIK the Intel CPUs are masking this icache problem, by having a icache
prefetcher and optimizing how fast the CPU can load/refill from higher
level caches.  Intel CPUs have a lot of HW-logic around this, which the
I assume the smaller CPUs don't.  E.g. quote from Intel Optimization
Reference Manual:

 "The instruction fetch unit (IFU) can fetch up to 16 bytes of aligned
  instruction bytes each cycle from the instruction cache to the
  instruction length decoder (ILD). The instruction queue (IQ) buffers
  the ILD-processed instructions and can deliver up to four instructions
  in one cycle to the instruction decoder."

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
