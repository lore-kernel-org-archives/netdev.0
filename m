From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] NUMA aware allocation of transmit and receive buffers
 for e1000
Date: Tue, 17 May 2005 21:58:45 -0700
Message-ID: <20050517215845.2f87be2f.akpm@osdl.org>
References: <Pine.LNX.4.62.0505171854490.20408@graphe.net>
	<20050517190343.2e57fdd7.akpm@osdl.org>
	<Pine.LNX.4.62.0505171941340.21153@graphe.net>
	<20050517.195703.104034854.davem@davemloft.net>
	<Pine.LNX.4.62.0505172125210.22920@graphe.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, linux-kernel@vger.kernel.org,
	netdev@oss.sgi.com, shai@scalex86.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S262086AbVERE7h@vger.kernel.org>
To: Christoph Lameter <christoph@lameter.com>
In-Reply-To: <Pine.LNX.4.62.0505172125210.22920@graphe.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Christoph Lameter <christoph@lameter.com> wrote:
>
> On Tue, 17 May 2005, David S. Miller wrote:
> 
> > > Because physically contiguous memory is usually better than virtually 
> > > contiguous memory? Any reason that physically contiguous memory will 
> > > break the driver?
> > 
> > The issue is whether size can end up being too large for
> > kmalloc() to satisfy, whereas vmalloc() would be able to
> > handle it.
> 
> Oww.. We need a NUMA aware vmalloc for this?  

I think the e1000 driver is being a bit insane there.  I figure that
sizeof(struct e1000_buffer) is 28 on 64-bit, so even with 4k pagesize we'll
always succeed in being able to support a 32k/32 = 1024-entry Tx ring.  

Is there any real-world reason for wanting larger ring sizes than that?
