From: Anton Blanchard <anton@samba.org>
Subject: Re: e1000 performance hack for ppc64 (Power4)
Date: Sat, 14 Jun 2003 10:55:34 +1000
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20030614005534.GF32097@krispykreme>
References: <C6F5CF431189FA4CBAEC9E7DD5441E010107D93A@orsmsx402.jf.intel.com> <20030613.165250.41635765.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: scott.feldman@intel.com, haveblue@us.ibm.com, hdierks@us.ibm.com,
	dwg@au1.ibm.com, linux-kernel@vger.kernel.org, milliner@us.ibm.com,
	ricardoz@us.ibm.com, twichell@us.ibm.com, netdev@oss.sgi.com
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20030613.165250.41635765.davem@redhat.com>
List-Id: netdev.vger.kernel.org

 
> So Anton, when the PCI controller gets a set of sub-cacheline word
> reads from the device, it reads the value from memory once for every
> one of those words?  ROFL, if so...  I can't believe they wouldn't
> put caches on the PCI controller for this, at least a one-behind that
> snoops the bus :(

There is a cache in the host bridge and the PCI-PCI bridge. I dont
think we go back to memory for sub cacheline reads.

What I think is happening is that we arent tripping the prefetch logic.
We should take a latency hit for only the first cacheline at which point
the host bridge decides to start prefetching for us. If not then we take
take the latency hit on each transaction.

Anton
