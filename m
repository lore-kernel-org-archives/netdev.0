From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH nf-next-2.6 2/2] conntrack: per_cpu untracking
Date: Tue, 08 Jun 2010 16:29:24 +0200
Message-ID: <4C0E53C4.7090308@trash.net>
References: <1271941082.14501.189.camel@jdb-workstation>	 <1271948029.7895.5707.camel@edumazet-laptop>	 <20100422155123.GA2524@linux.vnet.ibm.com>	 <1271952128.7895.5851.camel@edumazet-laptop>	 <Pine.LNX.4.64.1004222213290.10919@ask.diku.dk>	 <1272056237.4599.7.camel@edumazet-laptop>	 <Pine.LNX.4.64.1004241219280.32071@ask.diku.dk>	 <1272139861.20714.525.camel@edumazet-laptop>	 <1272292568.13192.43.camel@jdb-workstation>	 <1275340896.2478.26.camel@edumazet-laptop>	 <AANLkTikw3uonDB4nPXg8FVFN_07F_wq0SA_ayyAHL6VM@mail.gmail.com>	 <1275368732.2478.88.camel@edumazet-laptop> <4C04DE73.6050605@trash.net>	 <1275388310.2738.2.camel@edumazet-laptop> <4C04E3E2.7020209@trash.net>	 <1275409203.2738.227.camel@edumazet-laptop> <4C08E62A.9020607@trash.net>	 <AANLkTilKEpFTg5bH8d9UE3a3DVJNAGYz10Jgkt6lXtJ0@
 mail.gmail.com>	 <4C08F1A4.2050906@trash.net>  <1275654964.2482.150.camel@edumazet-laptop>	 <1275668732.2482.201.camel@edumazet-laptop> <1275682522.2490.6.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Changli Gao <xiaosuo@gmail.com>,
	Netfilter Developers <netfilter-devel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1275682522.2490.6.camel@edumazet-laptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04.06.2010 22:15, Eric Dumazet wrote:
> NOTRACK makes all cpus share a cache line on nf_conntrack_untracked
> twice per packet, slowing down performance.
> 
> This patch converts it to a per_cpu variable.
> 
> We assume same cpu is used for a given packet, entering and exiting the
> NOTRACK state.

That doesn't seem to be a valid assumption, the conntrack entry is
attached to the skb and processing in the output path might get
preempted and rescheduled to a different CPU.
