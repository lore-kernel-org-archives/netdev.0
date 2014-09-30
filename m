From: Amir Vadai <amirv@mellanox.com>
Subject: Re: [PATCH v2 net-next] mlx4: optimize xmit path
Date: Tue, 30 Sep 2014 15:01:48 +0300
Message-ID: <542A9BAC.6010208@mellanox.com>
References: <1411692382-8898-1-git-send-email-ast@plumgrid.com>	 <1411694414.16953.70.camel@edumazet-glaptop2.roam.corp.google.com>	 <1411717322.16953.99.camel@edumazet-glaptop2.roam.corp.google.com>	 <1411850590.15768.6.camel@edumazet-glaptop2.roam.corp.google.com>	 <CAJ3xEMhQCf7j48Yn5sjH6jaYYdLQUgOe2hk-OZhhdZ7taOyx+Q@mail.gmail.com>	 <1411853441.15768.13.camel@edumazet-glaptop2.roam.corp.google.com>	 <1411858593.15768.51.camel@edumazet-glaptop2.roam.corp.google.com> <1411964353.30721.6.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: Alexei Starovoitov <ast@plumgrid.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Eric Dumazet <edumazet@google.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Or Gerlitz <or.gerlitz@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog132.obsmtp.com ([207.126.144.207]:54672 "EHLO
	eu1sys200aog132.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750791AbaI3MCB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Sep 2014 08:02:01 -0400
In-Reply-To: <1411964353.30721.6.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/29/2014 7:19 AM, Eric Dumazet wrote:
> First I implemented skb->xmit_more support, and pktgen throughput
> went from ~5Mpps to ~10Mpps.
> 
> Then, looking closely at this driver I found false sharing problems that
> should be addressed by this patch, as my pktgen now reaches 14.7 Mpps
> on a single TX queue, with a burst factor of 8.
> 
> So this patch in a whole permits to improve raw performance on a single
> TX queue from about 5 Mpps to 14.9 Mpps.
> 
> Note that if packets are below the inline_thold threshold (104 bytes),
> driver copies packets content into tx descriptor, and throughput
> is lowered to ~7.5 Mpps :
> ->      We might reconsider inline strategy in a followup patch.
> 
> I could split this patch into multiple components, but I prefer not
> spend days on this work.

Hi,

Thanks for the great work Eric.

I'm working to split the patch and pass it through some regression tests
and performance benchmarking.
Will send the split patch-set in few days.

Amir
