From: Andi Kleen <ak@muc.de>
Subject: Re: [PATCH] NUMA aware allocation of transmit and receive buffers for e1000
Date: 30 May 2005 11:41:07 +0200
Message-ID: <20050530094107.GJ86087@muc.de>
References: <Pine.LNX.4.62.0505171854490.20408@graphe.net> <m1sm0l5lwa.fsf@muc.de> <428AF378.5020109@cosmosbay.com> <Pine.LNX.4.62.0505271413560.25484@graphe.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <dada1@cosmosbay.com>, netdev@oss.sgi.com, akpm@osdl.org,
        shai@scalex86.org
Return-path: <netdev-bounce@oss.sgi.com>
Date: Mon, 30 May 2005 11:41:07 +0200
To: Christoph Lameter <christoph@lameter.com>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.62.0505271413560.25484@graphe.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, May 27, 2005 at 02:15:55PM -0700, Christoph Lameter wrote:
> On Wed, 18 May 2005, Eric Dumazet wrote:
> 
> > Related question, is pci_alloc_consistent() already NUMA aware ?
> 
> Nope. It also ultimately acquires memory via vmalloc.

x86-64 vmalloc has been NUMA aware forever.
I believe the HP BigTux patchkit for IA64 added it there too, although
it might not have hit mainline.

> 
> pci_alloc_consistent will also need some rework to allocate memory 
> consistent (well the name is coherent right?) with the node that the 
> device is on. Second case of a need for a node aware vmalloc?

You can already have it today by temporarily changing the process
mempolicy. However for pci_alloc_consistent just using alloc_pages_node
directly seems to work fine. 

-Andi
