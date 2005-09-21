From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: [PATCH 0/3] netfilter : 3 patches to boost ip_tables performance
Date: Wed, 21 Sep 2005 15:43:29 -0700 (PDT)
Message-ID: <Pine.LNX.4.62.0509211542210.13045@schroedinger.engr.sgi.com>
References: <432EF0C5.5090908@cosmosbay.com> <200509191948.55333.ak@suse.de>
 <432FDAC5.3040801@cosmosbay.com> <200509201830.20689.ak@suse.de>
 <433082DE.3060308@cosmosbay.com> <43308324.70403@cosmosbay.com>
 <4331CFA7.50104@cosmosbay.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	netdev@vger.kernel.org, Andi Kleen <ak@suse.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S965107AbVIUWnx@vger.kernel.org>
To: Eric Dumazet <dada1@cosmosbay.com>
In-Reply-To: <4331CFA7.50104@cosmosbay.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 21 Sep 2005, Eric Dumazet wrote:

> Instead of using one vmalloc() area (located in the node of the iptables
> process), we now allocate an area for each possible CPU, using NUMA policy
> (MPOL_PREFERRED) so that memory should be allocated in the CPU's node
> if possible.
> 
> If the size of ipt_table is small enough (less than one page), we use
> kmalloc_node() instead of vmalloc(), to use less memory and less TLB entries)
> in small setups.

Maybe we better introduce vmalloc_node() instead of improvising this for 
several subsystems? The e1000 driver has similar issues.
