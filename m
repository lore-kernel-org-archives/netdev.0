From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] NUMA aware allocation of transmit and receive buffers
 for e1000
Date: Wed, 18 May 2005 13:42:50 -0700
Message-ID: <20050518134250.3ee2703f.akpm@osdl.org>
References: <Pine.LNX.4.62.0505171854490.20408@graphe.net>
	<20050517190343.2e57fdd7.akpm@osdl.org>
	<Pine.LNX.4.62.0505171941340.21153@graphe.net>
	<20050517.195703.104034854.davem@davemloft.net>
	<Pine.LNX.4.62.0505172125210.22920@graphe.net>
	<20050517215845.2f87be2f.akpm@osdl.org>
	<5fc59ff305051808558f1ce59@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: christoph@lameter.com, davem@davemloft.net,
	linux-kernel@vger.kernel.org, netdev@oss.sgi.com, shai@scalex86.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S262356AbVERUnU@vger.kernel.org>
To: Ganesh Venkatesan <ganesh.venkatesan@gmail.com>
In-Reply-To: <5fc59ff305051808558f1ce59@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ganesh Venkatesan <ganesh.venkatesan@gmail.com> wrote:
>
> On 5/17/05, Andrew Morton <akpm@osdl.org> wrote:
> > I think the e1000 driver is being a bit insane there.  I figure that
> Do you mean insane to use vmalloc?
> 
> > sizeof(struct e1000_buffer) is 28 on 64-bit, so even with 4k pagesize we'll
> > always succeed in being able to support a 32k/32 = 1024-entry Tx ring.
> > 
> > Is there any real-world reason for wanting larger ring sizes than that?
> > 
> > 
> We have had cases where allocation of 32K of memory (via kmalloc) fails. 
> 

Are you sure?  The current page allocator will infinitely loop until
success for <=32k GFP_KERNEL allocations - the only way it can fail is if
the calling process gets oom-killed.
