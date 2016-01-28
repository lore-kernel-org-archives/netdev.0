From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Bypass at packet-page level (Was: Optimizing instruction-cache,
 more packets at each stage)
Date: Thu, 28 Jan 2016 08:43:37 -0800
Message-ID: <1453999417.7627.45.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1453330945.1223.329.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CALx6S34H67o64q3YoYiHQ+VSSuSsuSjBXmexSSXF_Hq8fcN0iw@mail.gmail.com>
	 <20160121122730.6330a84b@redhat.com>
	 <20160121.105401.1793719917762270884.davem@davemloft.net>
	 <20160124152814.2ea5e99b@redhat.com>
	 <20160124163846-mutt-send-email-mst@redhat.com>
	 <56A509C4.3030706@gmail.com> <20160125141516.795f3eb7@redhat.com>
	 <CALx6S37EmUh7SXmVSjTN9DLMTicr6-VwL-i25VV1fM=V2E6giQ@mail.gmail.com>
	 <56A66058.1090308@gmail.com> <20160125231016.4f0d2cd5@redhat.com>
	 <20160127214750.51fe2392@redhat.com>
	 <CALx6S350ra6fmZrcabasndWBq4A3L-xKLS__jy1gi3xmhMc=sA@mail.gmail.com>
	 <20160128102530.5c07a8e7@redhat.com>
	 <1453985153.7627.8.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CALx6S36nQ6-PnyDUrQseeeNYJM1wnPSkjcERw0GehzMYSUxR6w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
	John Fastabend <john.fastabend@gmail.com>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	David Miller <davem@davemloft.net>,
	Or Gerlitz <gerlitz.or@gmail.com>,
	Eric Dumazet <edumazet@google.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Daniel Borkmann <borkmann@iogearbox.net>,
	Marek Majkowski <marek@cloudflare.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Florian Westphal <fw@strlen.de>,
	Paolo Abeni <pabeni@redhat.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Amir Vadai <amirva@gmail.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Vladislav Yasevich <vyasevich@gmail.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f67.google.com ([209.85.220.67]:35312 "EHLO
	mail-pa0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754877AbcA1Qnk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jan 2016 11:43:40 -0500
Received: by mail-pa0-f67.google.com with SMTP id gi1so2247273pac.2
        for <netdev@vger.kernel.org>; Thu, 28 Jan 2016 08:43:40 -0800 (PST)
In-Reply-To: <CALx6S36nQ6-PnyDUrQseeeNYJM1wnPSkjcERw0GehzMYSUxR6w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-01-28 at 08:37 -0800, Tom Herbert wrote:

> skbs are enqueued on a CPU queue one at at time through
> enqueue_to_backlog. It would be nice to do that as a batch of skbs.

Adding yet another layer and cache misses.

This might be a win for stress situations, not for nominal traffic,
when very few packets are delivered per NAPI poll.

For stress situations, we do not rely on RPS/RFS at all, but prefer RSS
and appropriate number of RX queues, to have true silos.

For the router case, where Jesper wants 15 Mpps on a single core,
RPS/RFS is not used.
