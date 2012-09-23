From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 2/7][RFC] netfilter: add xt_qtaguid matching module
Date: Sun, 23 Sep 2012 23:26:36 +0200
Message-ID: <20120923212636.GA1141@1984>
References: <1348279853-44499-1-git-send-email-john.stultz@linaro.org>
 <1348279853-44499-3-git-send-email-john.stultz@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: LKML <linux-kernel@vger.kernel.org>, JP Abgrall <jpa@google.com>,
	netdev@vger.kernel.org, Ashish Sharma <ashishsharma@google.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	netfilter-devel@vger.kernel.org
To: John Stultz <john.stultz@linaro.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1348279853-44499-3-git-send-email-john.stultz@linaro.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi John,

Cc'ing netfilter-devel (better than only netdev, to attract the
attention from other Netfilter hacker fellows).

Some comments on this:

On Fri, Sep 21, 2012 at 10:10:48PM -0400, John Stultz wrote:
> From: JP Abgrall <jpa@google.com>
> 
> This module allows tracking stats at the socket level for given UIDs.
> It replaces xt_owner.
> If the --uid-owner is not specified, it will just count stats based on
> who the skb belongs to. This will even happen on incoming skbs as it
> looks into the skb via xt_socket magic to see who owns it.
> If an skb is lost, it will be assigned to uid=0.
> 
> To control what sockets of what UIDs are tagged by what, one uses:
>   echo t $sock_fd $accounting_tag $the_billed_uid \
>      > /proc/net/xt_qtaguid/ctrl
>  So whenever an skb belongs to a sock_fd, it will be accounted against
>    $the_billed_uid
>   and matching stats will show up under the uid with the given
>    $accounting_tag.
> 
> Because the number of allocations for the stats structs is not that big:
>   ~500 apps * 32 per app
> we'll just do it atomic. This avoids walking lists many times, and
> the fancy worker thread handling. Slabs will grow when needed later.
> 
> It use netdevice and inetaddr notifications instead of hooks in the core dev
> code to track when a device comes and goes. This removes the need for
> exposed iface_stat.h.
> 
> Put procfs dirs in /proc/net/xt_qtaguid/
>   ctrl
>   stats
>   iface_stat/<iface>/...
> The uid stats are obtainable in ./stats.

Unless I'm missing anything worth in this patch, this seems to me like
a combo match of owner + nfacct infrastructure.

I guess you can probably get all done with one single rule, but that
is not enough to justify its inclusion in mainline.

In case you are not familiar with the nfacct infrastructure:

http://lwn.net/Articles/472094/

I'd be happy anyway if you provide more examples on you use this, so I
can assure you we can do this with the existing infrastructure in
mainstream.

Thanks!
