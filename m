From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH v3 net-next] tc: remove unused redirect ttl
Date: Sun, 3 May 2015 17:28:42 +0200
Message-ID: <20150503172842.42379466@redhat.com>
References: <1430543983-10446-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, "David S. Miller" <davem@davemloft.net>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49959 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750887AbbECP2t (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 May 2015 11:28:49 -0400
In-Reply-To: <1430543983-10446-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri,  1 May 2015 22:19:43 -0700
Alexei Starovoitov <ast@plumgrid.com> wrote:

> From: Jamal Hadi Salim <jhs@mojatatu.com>
> 
> improves ingress+u32 performance from 22.4 Mpps to 22.9 Mpps

I like this change and I'm ACKing it.

But I would like to comment on these performance numbers.  I assume this
is a single CPU test with your pktgen RX/STACK_INJECT mode that drops
the packet "early (in ip_rcv() I think).

It sound impressive to get +0.5 Mpps improvement from such a small
change, while in reality this is approx a 1ns improvement.

 (1/(22.4*10^6)*10^9) = 44.64ns
 (1/(22.9*10^6)*10^9) = 43.67ns
 improvement diff     =  0.97ns

I'm a fan of zooming in on parts of the stack, as it allow us to
performance optimize and measure parts of the stack that is normally
hard to measure. And your ingress use-case is valid.  People should
just be aware, that we can easily "over-sell" when "zooming" in...


> Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
> Acked-by: Florian Westphal <fw@strlen.de>
> Acked-by: Daniel Borkmann <daniel@iogearbox.net>

Acked-by: Jesper Dangaard Brouer <brouer@redhat.com>

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
