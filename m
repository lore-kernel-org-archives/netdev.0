From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: Optimizing instruction-cache, more packets at each stage
Date: Fri, 15 Jan 2016 15:00:25 +0100
Message-ID: <20160115150025.13a5db04@redhat.com>
References: <20160115142223.1e92be75@redhat.com>
	<063D6719AE5E284EB5DD2968C1650D6D1CCC6613@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Daniel Borkmann <borkmann@iogearbox.net>,
	Marek Majkowski <marek@cloudflare.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Florian Westphal <fw@strlen.de>,
	Paolo Abeni <pabeni@redhat.com>,
	John Fastabend <john.r.fastabend@intel.com>, brouer@redhat.com
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55083 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750894AbcAOOAd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Jan 2016 09:00:33 -0500
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CCC6613@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 15 Jan 2016 13:36:04 +0000
David Laight <David.Laight@ACULAB.COM> wrote:

> From: Jesper Dangaard Brouer
> > Sent: 15 January 2016 13:22
> ...
> > I want to do some instruction-cache level optimizations.
> > 
> > What do I mean by that...
> > 
> > The kernel network stack code path (a packet travels) is obviously
> > larger than the instruction-cache (icache).  Today, every packet
> > travel individually through the network stack, experiencing the exact
> > same icache misses (as the previous packet).
> ...
> 
> Is that actually true for modern server processors that have large i-cache.
> While the total size of the networking code may well be larger, that
> part used for transmitting data packets will be much be smaller and
> could easily fit in the icache.

Yes, exactly. That is what I'm betting on. If I can split it into
stages (e.g. part used for transmitting) that fits into icache then I
should see a win.

The icache is still quite small 32Kb on modern server processors.  I
don't know if smaller embedded processors also have icache and how
large they are.  I speculate this approach would also be a benefit for
them (if they have icache).

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
