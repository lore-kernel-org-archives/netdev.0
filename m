From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH] bridge: make it possible for packets to traverse the
 bridge withour hitting netfilter
Date: Fri, 13 Feb 2015 17:37:03 +0100
Message-ID: <20150213163703.GC15141@breakpoint.cc>
References: <1423560744-19011-1-git-send-email-imrep.amz@gmail.com>
 <20150211.142936.951620487173949333.davem@davemloft.net>
 <54DE2174.6040001@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	bridge@lists.linux-foundation.org, stephen@networkplumber.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	imrep@amazon.de, aliguori@amazon.com
To: Imre Palik <imrep.amz@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <54DE2174.6040001@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Imre Palik <imrep.amz@gmail.com> wrote:
> On 02/11/15 23:29, David Miller wrote:
> > If I apply this, someone is going to try to submit a patch for every
> > damn protocol layer to add a stupid hack like this.
> 
> Actually this is one of those patches.  There is already a "stupid hack like this" for iptables and arptables.  (Implemented before git history, and giving me 10% speedup.  Many thanks, whoever did it.)
> 
> I also searched various LKML archives, and it seems the existing "stupid hacks" for iptables and arptables haven't resulted in any related patch submission in the last ten years.  (Or my google-fu is weak.)
> 
> Moreover, I cannot imagine any other reasonable on/off switch for bridge-netfilter than these three.  Of course, my imagination might be lacking there.

Why do you load the bridge netfilter module if you don't want it?
Loading it registers the internal hooks for the call-ip(6)tables and
sabotage hooks with NF_BRIDGE protocol so most of the NF_HOOK(NF_BRIDGE, ...
calls become active.
