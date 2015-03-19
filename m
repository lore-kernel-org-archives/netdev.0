From: Florian Westphal <fw@strlen.de>
Subject: Re: cgroup matches in INPUT chain
Date: Thu, 19 Mar 2015 19:58:07 +0100
Message-ID: <20150319185807.GA3845@breakpoint.cc>
References: <550B1852.2020209@zonque.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Borkmann <dborkman@redhat.com>,
	Alexey Perevalov <a.perevalov@samsung.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	netdev <netdev@vger.kernel.org>
To: Daniel Mack <daniel@zonque.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:43369 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751294AbbCSS6O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2015 14:58:14 -0400
Content-Disposition: inline
In-Reply-To: <550B1852.2020209@zonque.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Daniel Mack <daniel@zonque.org> wrote:
> In my tests, however, NF_INET_LOCAL_IN is iterated before early_demux()
> is called,

Early demux occurs after PRE_ROUTING but before LOCAL_IN.

Otherwise edemux would make little sense since its used to avoid the
routing lookup that decides wheter skb has to be locally delivered or
forwarded. IOW, in NF_INET_LOCAL_IN we've already decided on local
delivery and would not need a 'early' socket lookup any more.
