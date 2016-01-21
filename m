From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Optimizing instruction-cache, more packets at each stage
Date: Thu, 21 Jan 2016 08:38:08 -0800
Message-ID: <1453394288.1223.368.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20160115142223.1e92be75@redhat.com>
	 <20160115.154721.458450438918273509.davem@davemloft.net>
	 <20160118112703.6eac71ca@redhat.com>
	 <20160118.112455.212265265553435873.davem@davemloft.net>
	 <CAJ3xEMiOAdu7ghRoc6ZEMG78Z9xyh1M=5Egc3ydh+97bT3_9fw@mail.gmail.com>
	 <1453330945.1223.329.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CALx6S34H67o64q3YoYiHQ+VSSuSsuSjBXmexSSXF_Hq8fcN0iw@mail.gmail.com>
	 <20160121122730.6330a84b@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <tom@herbertland.com>,
	Or Gerlitz <gerlitz.or@gmail.com>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Daniel Borkmann <borkmann@iogearbox.net>,
	Marek Majkowski <marek@cloudflare.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Florian Westphal <fw@strlen.de>,
	Paolo Abeni <pabeni@redhat.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Amir Vadai <amirva@gmail.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:33608 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759914AbcAUQiL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jan 2016 11:38:11 -0500
Received: by mail-pa0-f47.google.com with SMTP id cy9so25762621pac.0
        for <netdev@vger.kernel.org>; Thu, 21 Jan 2016 08:38:10 -0800 (PST)
In-Reply-To: <20160121122730.6330a84b@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-01-21 at 12:27 +0100, Jesper Dangaard Brouer wrote:

> In my experiments, where I extract several packet before calling
> napi_gro_receive(), and I also delay calling eth_type_trans().  Most of
> my speedup comes from this trick, as the prefetch() now that enough
> time.

It really depends on the cpu.

Many cpus have very poor prefetch performance.
prefetch instructions are lazily defined by Intel/AMD

Ivy Bridge prefetcher for example is known to be not that good.

http://www.agner.org/optimize/blog/read.php?i=415

http://www.agner.org/optimize/blog/read.php?i=285

https://groups.google.com/forum/#!topic/comp.arch/71wnqr_F9sw

Really, refrain from adding stuff that might look good one one cpu.
