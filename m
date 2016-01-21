From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: Optimizing instruction-cache, more packets at each stage
Date: Thu, 21 Jan 2016 13:23:04 +0100
Message-ID: <20160121132304.12ff9d23@redhat.com>
References: <20160115142223.1e92be75@redhat.com>
	<20160115.154721.458450438918273509.davem@davemloft.net>
	<20160118112703.6eac71ca@redhat.com>
	<20160118.112455.212265265553435873.davem@davemloft.net>
	<CAJ3xEMiOAdu7ghRoc6ZEMG78Z9xyh1M=5Egc3ydh+97bT3_9fw@mail.gmail.com>
	<1453330945.1223.329.camel@edumazet-glaptop2.roam.corp.google.com>
	<CALx6S34H67o64q3YoYiHQ+VSSuSsuSjBXmexSSXF_Hq8fcN0iw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
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
	Amir Vadai <amirva@gmail.com>, brouer@redhat.com
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49044 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758886AbcAUMXM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Jan 2016 07:23:12 -0500
In-Reply-To: <CALx6S34H67o64q3YoYiHQ+VSSuSsuSjBXmexSSXF_Hq8fcN0iw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 20 Jan 2016 15:27:38 -0800
Tom Herbert <tom@herbertland.com> wrote:

> weaknesses of Toeplitz we talked about recently and that fact that
> Jenkins is really fast to compute, I am starting to think maybe we
> should always do a software hash and not rely on HW for it...

Please don't enforce a software hash.  You are proposing a hash
computation per packet which cost in the area 50-100 nanosec (?). And
on data which is cache cold (even with DDIO, you take the L3 cache
cost/hit).

Consider the increase in network hardware speeds.

Worst-case (pkt size 64 bytes) time between packets:
 *  10 Gbit/s -> 67.2 nanosec
 *  40 Gbit/s -> 16.8 nanosec
 * 100 Gbit/s ->  6.7 nanosec

Adding such a per packet cost is not going to fly.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
