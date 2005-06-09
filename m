From: "David S. Miller" <davem@davemloft.net>
Subject: Re: RFC: NAPI packet weighting patch
Date: Thu, 09 Jun 2005 15:22:28 -0700 (PDT)
Message-ID: <20050609.152228.112623409.davem@davemloft.net>
References: <1118237775.6382.34.camel@localhost.localdomain>
	<Pine.LNX.4.62.0506091406590.10396@ladlxr>
	<20050609150546.61b0fee7@unknown-215.office.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jesse.brandeburg@intel.com, hadi@cyberus.ca, john.ronciak@intel.com,
        mitch.a.williams@intel.com, mchan@broadcom.com, buytenh@wantstofly.org,
        jdmason@us.ibm.com, netdev@oss.sgi.com, Robert.Olsson@data.slu.se,
        ganesh.venkatesan@intel.com
Return-path: <netdev-bounce@oss.sgi.com>
To: shemminger@osdl.org
In-Reply-To: <20050609150546.61b0fee7@unknown-215.office.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Thu, 9 Jun 2005 15:05:46 -0700

> > I have profile data, here is an example of 5tx/5rx threads, where the 
> > throughput was 1236Mb/s total, 936tx, 300rx, on 2.6.12-rc5 with old TSO 
> > (the original problem case) we are at 100% cpu and generating 3289 ints/s, 
> > with no hardware drops reported prolly due to my replenish patch
> > CPU: P4 / Xeon with 2 hyper-threads, speed 2791.36 MHz (estimated)
> > Counted GLOBAL_POWER_EVENTS events (time during which processor is not stopped) with a unit mask of 0x01 (mandatory) count 100000
> > samples  %        image name       symbol name
> > 533687    8.1472  vmlinux          pskb_expand_head
> > 428726    6.5449  vmlinux          __copy_user_zeroing_intel
> > 349934    5.3421  vmlinux          _read_lock_irqsave
> 
> We should kill all reader/writer locks in the fastpath. reader locks are
> more expensive than spinlocks unless they are going to be held for a fairly
> large window.

True, but I see no reason why it should have any influence here.
Let's not get distracted by this in our analysis of the problem.
