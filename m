From: Andi Kleen <ak@suse.de>
Subject: Re: Route cache performance under stress
Date: Mon, 9 Jun 2003 12:13:02 +0200
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030609101302.GA9643@wotan.suse.de>
References: <20030609081803.GF20613@netnation.com> <20030609.020116.10308258.davem@redhat.com> <20030609094734.GD2728@wotan.suse.de> <20030609.030334.02284330.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ak@suse.de, sim@netnation.com, xerox@foonet.net, fw@deneb.enyo.de,
	netdev@oss.sgi.com, linux-net@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, Robert.Olsson@data.slu.se
Return-path: <linux-net-owner@vger.kernel.org>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20030609.030334.02284330.davem@redhat.com>
List-Id: netdev.vger.kernel.org

On Mon, Jun 09, 2003 at 03:03:34AM -0700, David S. Miller wrote:
>    From: Andi Kleen <ak@suse.de>
>    Date: Mon, 9 Jun 2003 11:47:34 +0200
>    
>    gcc will generate a lot better code for the memsets if you can tell
>    it somehow they are long aligned and a multiple of 8 bytes.
> 
> True, but the real bug is that we're initializing any of this
> crap here at all.  Right now we write over the same cachelines
> 3 or so times.  It should really just happen once.

It's unlikely to be the reason for the profile hit on a modern x86.
They are all really fast at reading/writing L1. 

More likely it is the cache miss for fetching the lines initially.
Perhaps it is cache thrashing the dst_entry heads. Adding a strategic
prefetch somewhere early may help a lot.

-Andi
