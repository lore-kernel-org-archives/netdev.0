From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH] iptables: lock free counters
Date: Fri, 20 Feb 2009 16:35:29 -0800
Message-ID: <499F4C51.7010302@hp.com>
References: <20090218051906.174295181@vyatta.com>	<20090218052747.321329022@vyatta.com>	<20090219114719.560999b5@extreme>	<499DEF49.3040602@cosmosbay.com>	<499DF1A2.1030405@hp.com>	<20090219170318.3f7d54f2@extreme>	<499E04C9.4020308@hp.com> <499E7B03.9090409@trash.net> <499F3551.5@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Eric Dumazet <dada1@cosmosbay.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <499F3551.5@hp.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rick Jones wrote:
> So, by the time this hits inboxes, under:
> 
> ftp://ftp.netperf.org/nf-next-2.6-results
> ...
> I will go back through my email now and try to find the conntrack lock 
> changes and apply them to the tree and turn the crank.

Under the base URL above there is now a "conntrack" subdir with the usual "none," 
"empty," and "full" subdirs.  This is with the patch from message ID 
<20090219140303.4329f860@extreme> titled "Re: [RFT 4/4] netfilter: Get rid of 
central rwlock in tcp conntracking" which my mail client says has a date of 
02/19/09 14:03.

On the plus side, only one of the 64 concurrent netperfs died during the "full" 
test compared with more than 10 without the patch.  Also, there were no soft 
lockups reported as there were without the patch.

The rwlock time is gone, naturally, replaced with boatloads of spinlock 
contention.  Hopefully the scgprof profile will help show the source.  Perhaps 
there is yet another patch I should have applied :)

happy benchmarking,

rick jones
