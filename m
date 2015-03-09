From: David Miller <davem@redhat.com>
Subject: Re: [PATCH 1/1] net: delete stale packet_mclist entries
Date: Mon, 09 Mar 2015 16:18:03 -0400 (EDT)
Message-ID: <20150309.161803.1868645188568473029.davem@redhat.com>
References: <20150309190952.5C6AA483316@fruggeri-Arora18.sjc.aristanetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	mst@redhat.com, al.drozdov@gmail.com, willemb@google.com,
	viro@zeniv.linux.org.uk, edumazet@google.com, dborkman@redhat.com,
	fruggeri@arista.com
To: fruggeri@aristanetworks.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150309190952.5C6AA483316@fruggeri-Arora18.sjc.aristanetworks.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: fruggeri@aristanetworks.com (Francesco Ruggeri)
Date: Mon, 09 Mar 2015 12:09:52 -0700

> From ce9a4f202723f6ba1b18bc7c4a258c130c1f4148 Mon Sep 17 00:00:00 2001
> From: Francesco Ruggeri <fruggeri@arista.com>
> Date: Mon, 9 Mar 2015 11:51:04 -0700
> Subject: [PATCH 1/1] net: delete stale packet_mclist entries
> 
> When an interface is deleted from a net namespace the ifindex in the
> corresponding entries in PF_PACKET sockets' mclists becomes stale.
> This can create inconsistencies if later an interface with the same ifindex
> is moved from a different namespace (not that unlikely since ifindexes are
> per-namespace).
> In particular we saw problems with dev->promiscuity, resulting
> in "promiscuity touches roof, set promiscuity failed. promiscuity
> feature of device might be broken" warnings and EOVERFLOW failures of
> setsockopt(PACKET_ADD_MEMBERSHIP).
> This patch deletes the mclist entries for interfaces that are deleted.
> Since this now causes setsockopt(PACKET_DROP_MEMBERSHIP) to fail with
> EADDRNOTAVAIL if called after the interface is deleted, also make
> packet_mc_drop not fail.
> 
> Signed-off-by: Francesco Ruggeri <fruggeri@arista.com>

Indeed, this is consistent with how we will fail an add of an MC list
entry if the ifindex doesn't resolve to an actual device.

Applied, thanks.

 
