From: Dipankar Sarma <dipankar@in.ibm.com>
Subject: Re: [PATCH] dst numa: Avoid dst counter cacheline bouncing
Date: Fri, 24 Jun 2005 10:28:54 +0530
Message-ID: <20050624045854.GA6465@in.ibm.com>
References: <Pine.LNX.4.62.0506231953260.28244@graphe.net> <Pine.LNX.4.62.0506232005030.28244@graphe.net>
Reply-To: dipankar@in.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net, shai@scalex86.org, akpm@osdl.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S263080AbVFXFBv@vger.kernel.org>
To: Christoph Lameter <christoph@lameter.com>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.62.0506232005030.28244@graphe.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 23, 2005 at 08:10:06PM -0700, Christoph Lameter wrote:
> The dst_entry structure contains an atomic counter that is incremented and
> decremented for each network packet being sent. If there is a high number of
> packets being sent from multiple processors then cacheline bouncing between
> NUMA nodes can limit the tcp performance in a NUMA system.
> 
> The following patch splits the usage counter into counters per node.
> 

Do we really need to do a distributed reference counter implementation
inside dst cache code ? If you are willing to wait for a while,
we should have modified Rusty's bigref implementation on top of the 
interleaving dynamic per-cpu allocator. We can look at distributed 
reference counter for dst refcount then and see how that can be 
worked out.

Thanks
Dipankar
