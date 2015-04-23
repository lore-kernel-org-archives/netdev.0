From: Florian Westphal <fw@strlen.de>
Subject: Re: [RFC 2/3] tc: deprecate TC_ACT_QUEUED
Date: Thu, 23 Apr 2015 23:20:42 +0200
Message-ID: <20150423212042.GA1627@breakpoint.cc>
References: <1429644476-8914-1-git-send-email-ast@plumgrid.com>
 <1429644476-8914-3-git-send-email-ast@plumgrid.com>
 <CAHA+R7MYcKTHmZWtHm9V5_DjdB0zTBhayhsftcqkDFMwCno7dg@mail.gmail.com>
 <55381F14.4070708@plumgrid.com>
 <553959E3.9070209@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexei Starovoitov <ast@plumgrid.com>,
	Cong Wang <cwang@twopensource.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	netdev <netdev@vger.kernel.org>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:55162 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1030714AbbDWVUw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Apr 2015 17:20:52 -0400
Content-Disposition: inline
In-Reply-To: <553959E3.9070209@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> 2) the ACT_QUEUED vs STOLEN was supposed to have semantics of something
> that was stolen (eg redirection should definetely have been returning
> STOLEN not QUEUED); something that queues for later re-injection
> (with any/all metadata) was intended to use QUEUED. I believe netfilter
> may have  followed suit and introduced similar codes (so it would be
> interesting to see how they use them).

Hooks (Targets) don't queue themselves, i.e. NF_QUEUE tells the
netfilter core that the skb is to be handed off to nf_queue machinery,
while NF_STOLEN is the more obvious "don't touch this skb ever again".
