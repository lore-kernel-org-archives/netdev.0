From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH nf-next 0/8] netfilter: untangle bridge and bridge
 netfilter
Date: Mon, 9 Mar 2015 18:35:15 +0100
Message-ID: <20150309173515.GB30297@breakpoint.cc>
References: <1425513160-496-1-git-send-email-fw@strlen.de>
 <20150309130253.GA6677@salvia>
 <20150309131356.GB28039@breakpoint.cc>
 <20150309.131613.2015932954920552655.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: fw@strlen.de, pablo@netfilter.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, azhou@nicira.com
To: David Miller <davem@redhat.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150309.131613.2015932954920552655.davem@redhat.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@redhat.com> wrote:
> > The 2nd (and last half) of the set folds nf_bridge_info into skbuff,
> > at the end (where its not initialized at allocation time).
> > 
> > The struct is a lot smaller by then (16 bytes on 64bit, 12 on 32bit)
> > so we'd increase skbuff size only by 8.
> 
> Sorry, increases in size of any kind of sk_buff are strongly discouraged.

No need to be sorry, its not a show-stopper.
Its the last patch in the series and nothing depends on this change.

> Especially for something like nfbridge.

Its not initialized, ever, if bridge is not used, so it shouldn't be a big
deal.  The goal of the entire exercise is to remove the need to zero
nf_bridge pointer at skb allocation time, so one of the patches in that
series moves it to the end of the skb.

The only reason why I added the 'fold it' patch on top is that after the
refactoring nf_bridge_info struct is just 16 bytes so it seemed
preferrable to me to add cost of 8 more bytes and get rid of the
nf_bridge refcounting at same time.

I'd just send it along with the series so everyone can look at it,
and, if you (or others) still prefer to keep the pointer then Pablo can
just drop it.
