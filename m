From: Amir Vadai <amirv@mellanox.com>
Subject: Re: ixgbe, don't assume mapping of numa node cpus
Date: Tue, 25 Feb 2014 19:27:29 +0200
Message-ID: <20140225172726.GA31074@mtl-eit-vdi-22.mtl.labs.mlnx>
References: <1393267913-28212-1-git-send-email-prarit@redhat.com>
 <1393267913-28212-3-git-send-email-prarit@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	Alex Duyck <alexander.h.duyck@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Mitch Williams <mitch.a.williams@intel.com>,
	"David S. Miller" <davem@davemloft.net>, nhorman@redhat.com,
	agospoda@redhat.com, e1000-devel@lists.sourceforge.net,
	idos@mellanox.com, Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: Prarit Bhargava <prarit@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f182.google.com ([209.85.212.182]:42301 "EHLO
	mail-wi0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753042AbaBYR1e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Feb 2014 12:27:34 -0500
Received: by mail-wi0-f182.google.com with SMTP id f8so1061390wiw.15
        for <netdev@vger.kernel.org>; Tue, 25 Feb 2014 09:27:33 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1393267913-28212-3-git-send-email-prarit@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 24/02/14 13:51 -0500, Prarit Bhargava wrote:
> The ixgbe driver assumes that the cpus on a node are mapped 1:1 with the
> indexes into arrays.  This is not the case as nodes can contain, for
> example, cpus 0-7, 33-40.
> 
> This patch fixes this problem.
> 
> Signed-off-by: Prarit Bhargava <prarit@redhat.com>
> Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Cc: Bruce Allan <bruce.w.allan@intel.com>
> Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>
> Cc: Don Skidmore <donald.c.skidmore@intel.com>
> Cc: Greg Rose <gregory.v.rose@intel.com>
> Cc: Alex Duyck <alexander.h.duyck@intel.com>
> Cc: John Ronciak <john.ronciak@intel.com>
> Cc: Mitch Williams <mitch.a.williams@intel.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: nhorman@redhat.com
> Cc: agospoda@redhat.com
> Cc: e1000-devel@lists.sourceforge.net
> ---

Hi,

I'm just about to send tomorrow a patch to add an helper function to
get affinity_hint suggestion by numa_node and ring index.
If you'd like you will be able to use it too here.

We're still doing internal review on it before sending to the mailing
list, but this will be the declaration of the function:
/*
 * netif_set_rx_queue_affinity_hint - set affinity hint of rx queue
 * @rxq: index of rx queue
 * @numa_node: prefered numa_node
 * @affinity_mask: the relevant cpu bit is set according to the policy
 *
 * This function sets the affinity_mask according to a numa aware policy.
 * affinity_mask coulbe used as an affinity hint for the IRQ related of this
 * rx queue.
 * The policy is to spread rx queues across cores - local cores first.
 *
 * Returns 0 on success, or a negative error code.
 */
int netif_set_rx_queue_affinity_hint(int rxq, int numa_node,
                                     cpumask_var_t affinity_mask);



Amir
