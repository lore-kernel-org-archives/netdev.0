From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: Optimizing instruction-cache, more packets at each stage
Date: Mon, 18 Jan 2016 18:49:48 +0100
Message-ID: <20160118184948.40b27e89@redhat.com>
References: <20160115142223.1e92be75@redhat.com>
	<20160115.154721.458450438918273509.davem@davemloft.net>
	<20160118112703.6eac71ca@redhat.com>
	<CALx6S37+9tXjrzuhgbsUDPOBEY8uS9Nitk4jE2z0ZZ+ufE-U+w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Daniel Borkmann <borkmann@iogearbox.net>, marek@cloudflare.com,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Florian Westphal <fw@strlen.de>,
	Paolo Abeni <pabeni@redhat.com>,
	John Fastabend <john.r.fastabend@intel.com>, brouer@redhat.com
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59333 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932217AbcARRt5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Jan 2016 12:49:57 -0500
In-Reply-To: <CALx6S37+9tXjrzuhgbsUDPOBEY8uS9Nitk4jE2z0ZZ+ufE-U+w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Mon, 18 Jan 2016 09:36:32 -0800 Tom Herbert <tom@herbertland.com> wrote:

> On Mon, Jan 18, 2016 at 2:27 AM, Jesper Dangaard Brouer
[...]
> > Down in the driver layer (RX), I think it is too early to categorize
> > Related/Unrelated SKB's, because we want to delay touching packet-data
> > as long as possible (waiting for the prefetcher to get data into
> > cache).
> >
> Does DDIO address this?

Data Direct IO (DDIO) delivers packet-data into L3 cache, which is
great to avoid this first cache miss on data.  But not all CPUs have
this feature.  And it is difficult to deduct which CPUs support this
feature.

For test purposes, I do have systems both with and without DDIO.

I'm currently setting up as Skylake CPU based system, which I believe
don't have DDIO.  The reason for this system is that, the Skylake CPU
should have better PMU support for profiling icache and front-end.
I'll soon verify this...

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
