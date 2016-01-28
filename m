From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Bypass at packet-page level (Was: Optimizing instruction-cache,
 more packets at each stage)
Date: Thu, 28 Jan 2016 05:25:43 -0800
Message-ID: <1453987543.7627.27.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20160121122730.6330a84b@redhat.com>
	 <20160121.105401.1793719917762270884.davem@davemloft.net>
	 <20160124152814.2ea5e99b@redhat.com>
	 <20160124163846-mutt-send-email-mst@redhat.com>
	 <56A509C4.3030706@gmail.com> <20160125141516.795f3eb7@redhat.com>
	 <CALx6S37EmUh7SXmVSjTN9DLMTicr6-VwL-i25VV1fM=V2E6giQ@mail.gmail.com>
	 <56A66058.1090308@gmail.com> <20160125231016.4f0d2cd5@redhat.com>
	 <20160127214750.51fe2392@redhat.com>
	 <20160127215601.GA52809@ast-mbp.thefacebook.com>
	 <20160128105255.083799a3@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	John Fastabend <john.fastabend@gmail.com>,
	Tom Herbert <tom@herbertland.com>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	David Miller <davem@davemloft.net>,
	Or Gerlitz <gerlitz.or@gmail.com>,
	Eric Dumazet <edumazet@google.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Daniel Borkmann <borkmann@iogearbox.net>,
	Marek Majkowski <marek@cloudflare.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Florian Westphal <fw@strlen.de>,
	Paolo Abeni <pabeni@redhat.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Amir Vadai <amirva@gmail.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Vladislav Yasevich <vyasevich@gmail.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:36654 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750818AbcA1NZq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jan 2016 08:25:46 -0500
Received: by mail-pa0-f43.google.com with SMTP id yy13so23238439pab.3
        for <netdev@vger.kernel.org>; Thu, 28 Jan 2016 05:25:46 -0800 (PST)
In-Reply-To: <20160128105255.083799a3@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-01-28 at 10:52 +0100, Jesper Dangaard Brouer wrote:

> I'm still in flux/undecided how long we should delay the first touching
> of pkt-data, which happens when calling eth_type_trans().  Should it
> stay in the driver or not(?).

Some cpus have limited prefetch capabilities.
Sometimes, prefetches need to be spaced, otherwise they are ignored.
A driver author might be tempted to 'optimize' its rx handler for few
cpus.

Also, removing eth_type_trans() from the drivers would require quite
some work, but would be generic and certainly helpful.
