From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: RFC:  MTU for serving NFS on Infiniband
Date: Mon, 23 Aug 2010 16:12:58 +0100
Message-ID: <1282576378.2267.20.camel@achroite.uk.solarflarecom.com>
References: <alpine.LNX.2.00.1008230842290.9325@abcyxhiz.aict.ualberta.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Marc Aurele La France <tsi@ualberta.ca>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.00.1008230842290.9325@abcyxhiz.aict.ualberta.ca>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2010-08-23 at 08:44 -0600, Marc Aurele La France wrote:
> My apologies for the multiple post.  I got bit the first time around by my 
> MUA's configuration.
> 
> ----
> 
> Greetings.
> 
> For some time now, the kernel and I have been having an argument over what 
> the MTU should be for serving NFS over Infiniband.  I say 65520, the 
> documented maximum for connected mode.  But, so far, I've been unable to have 
> anything over 32192 remain stable.
> 
> Back in the 2.6.14 -> .15 period, sunrpc's sk_buff allocations were changed 
> from GFP_KERNEL to GFP_ATOMIC (b079fa7baa86b47579f3f60f86d03d21c76159b8 
> mainstream commit).  Understandably, this was to prevent recursion through 
> the NFS and sunrpc code.  This is fine for the most common MTU out there, as 
> the kernel is almost certain to find a free page.  But, as one increases the 
> MTU, memory fragmentation starts to play a role in nixing these allocations.
[...]

I'm not familiar with the NFS server, but what you're saying suggests
that this code needs a more radical rethink.

Firstly, I don't see why NFS should require each packet's payload to be
contiguous.  It could use page fragments and then leave it to the
networking core to linearize the buffer if necessary for stupid
hardware.

Secondly, if it's doing its own segmentation it can't take advantage of
TSO.  This is likely to be a real drag on performance.  If it were
taking advantage of TSO then the effective MTU over TCP/IP could be
about 64K and it would already have hit this problem on Ethernet.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
