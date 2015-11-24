From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv6: distinguish frag queues by device for
 multicast and link-local packets
Date: Tue, 24 Nov 2015 16:46:25 -0500 (EST)
Message-ID: <20151124.164625.1632013093413416374.davem@davemloft.net>
References: <20151124140711.E07F2A0BE8@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	linux-kernel@vger.kernel.org, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, kaber@trash.net, pablo@netfilter.org,
	kadlec@blackhole.kfki.hu
To: mkubecek@suse.cz
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151124140711.E07F2A0BE8@unicorn.suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michal Kubecek <mkubecek@suse.cz>
Date: Tue, 24 Nov 2015 15:07:11 +0100 (CET)

> If a fragmented multicast packet is received on an ethernet device which
> has an active macvlan on top of it, each fragment is duplicated and
> received both on the underlying device and the macvlan. If some
> fragments for macvlan are processed before the whole packet for the
> underlying device is reassembled, the "overlapping fragments" test in
> ip6_frag_queue() discards the whole fragment queue.
> 
> To resolve this, add device ifindex to the search key and require it to
> match reassembling multicast packets and packets to link-local
> addresses.
> 
> Note: similar patch has been already submitted by Yoshifuji Hideaki in
> 
>   http://patchwork.ozlabs.org/patch/220979/
> 
> but got lost and forgotten for some reason.
> 
> Signed-off-by: Michal Kubecek <mkubecek@suse.cz>

This is definitely the right thing to do and matches how ipv4 keys
fragments.

Applied and queued up for -stable, thanks!
