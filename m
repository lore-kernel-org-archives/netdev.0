From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [rfc][patch 1/3] slub: fix small HWCACHE_ALIGN alignment
Date: Wed, 5 Mar 2008 13:06:30 -0800 (PST)
Message-ID: <Pine.LNX.4.64.0803051257030.30742@schroedinger.engr.sgi.com>
References: <20080303201701.GF8974@wotan.suse.de>
 <Pine.LNX.4.64.0803031315160.4131@schroedinger.engr.sgi.com>
 <20080305000637.GA1510@wotan.suse.de> <20080304.161003.129716254.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: npiggin@suse.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, yanmin_zhang@linux.intel.com,
	dada1@cosmosbay.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay1.sgi.com ([192.48.171.29]:58961 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753791AbYCEVGl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Mar 2008 16:06:41 -0500
In-Reply-To: <20080304.161003.129716254.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 4 Mar 2008, David Miller wrote:

> > Huh?? It is not a new definition, it is exactly what SLAB does. And
> > then you go and do something different and claim that you follow
> > what slab does.
> 
> I completely agree with Nick.

So you also want subalignment because of cacheline crossing for 24 byte 
slabs? We then only have 2 objects per cacheline instead of 3 but no 
crossing anymore.

Well okay if there are multiple requests then lets merge Nick's patch that 
does this. Still think that this will do much ...
Instead of 170 we will only have 128 objects per slab (64 byte 
cacheline).

It will affect the following slab caches (mm) reducing the density of 
objects. 

scsi_bidi_sdb numa_policy fasync_cache xfs_bmap_free_item xfs_dabuf 
fstrm_item dm_target_io

Nothing related to networking....
