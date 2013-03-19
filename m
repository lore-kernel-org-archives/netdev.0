From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Can we rely on ethernet header padding?
Date: Tue, 19 Mar 2013 08:21:35 -0700
Message-ID: <1363706495.2558.14.camel@edumazet-glaptop>
References: <20130319150545.GA18218@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Michal Kubecek <mkubecek@suse.cz>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20130319150545.GA18218@unicorn.suse.cz>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2013-03-19 at 16:05 +0100, Michal Kubecek wrote:
> Hello,
> 
> a customer of ours ran into
> 
>   http://bugzilla.netfilter.org/show_bug.cgi?id=765
> 
> They checked that commit a504b86e prevents the crash but I'm not sure it
> is sufficient.
> 
> The crash happens when br_nf_pre_routing_finish_bridge() calls
> neigh_hh_bridge() which copies not only destination MAC address but also
> the padding with it. IIUC this is for performance reasons (so that
> aligned 8 bytes are copied rather than 6).
> 
> But I wonder whether we can rely on the fact that every skb on an
> ethernet-like device has ethernet header padded at least to the 16 bytes
> expected by neigh_hh_bridge() and neigh_hh_output() or whether the
> bridge code should make sure. I tried to look for such test but couldn't
> find any, even if commit a504b86e description mentions reallocating the
> skb rather than a crash.

Thats a side effect.

Before calling netif_rx() the driver usually calls eth_type_trans()
to pull the ethernet header, so there is the room for 14 bytes.

Normally a driver has NET_SKB_PAD bytes of headroom before the ethernet
header, so the bridge code is safe only if all drivers use this
NET_SKB_PAD padding on receive side. And they really should for
performance reasons.

Better not touch bridge code to catch offending drivers





