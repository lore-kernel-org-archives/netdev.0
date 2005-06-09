From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: RFC: NAPI packet weighting patch
Date: Thu, 9 Jun 2005 15:05:46 -0700
Message-ID: <20050609150546.61b0fee7@unknown-215.office.pdx.osdl.net>
References: <468F3FDA28AA87429AD807992E22D07E0450C01F@orsmsx408>
	<20050607.132159.35660612.davem@davemloft.net>
	<Pine.LNX.4.62.0506071852290.31708@ladlxr>
	<20050607.204339.21591152.davem@davemloft.net>
	<1118237775.6382.34.camel@localhost.localdomain>
	<Pine.LNX.4.62.0506091406590.10396@ladlxr>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jamal <hadi@cyberus.ca>, "David S. Miller" <davem@davemloft.net>,
        "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
        "Ronciak, John"
 <john.ronciak@intel.com>,
        "Williams, Mitch A" <mitch.a.williams@intel.com>, mchan@broadcom.com,
        buytenh@wantstofly.org, jdmason@us.ibm.com, netdev@oss.sgi.com,
        Robert.Olsson@data.slu.se,
        "Venkatesan, Ganesh"
 <ganesh.venkatesan@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jesse Brandeburg <jesse.brandeburg@intel.com>
In-Reply-To: <Pine.LNX.4.62.0506091406590.10396@ladlxr>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


> I have profile data, here is an example of 5tx/5rx threads, where the 
> throughput was 1236Mb/s total, 936tx, 300rx, on 2.6.12-rc5 with old TSO 
> (the original problem case) we are at 100% cpu and generating 3289 ints/s, 
> with no hardware drops reported prolly due to my replenish patch
> CPU: P4 / Xeon with 2 hyper-threads, speed 2791.36 MHz (estimated)
> Counted GLOBAL_POWER_EVENTS events (time during which processor is not stopped) with a unit mask of 0x01 (mandatory) count 100000
> samples  %        image name       symbol name
> 533687    8.1472  vmlinux          pskb_expand_head
> 428726    6.5449  vmlinux          __copy_user_zeroing_intel
> 349934    5.3421  vmlinux          _read_lock_irqsave

We should kill all reader/writer locks in the fastpath. reader locks are
more expensive than spinlocks unless they are going to be held for a fairly
large window.


> 313667    4.7884  vmlinux          csum_partial
> 218870    3.3413  vmlinux          _spin_lock
> 214302    3.2715  vmlinux          __copy_user_intel
> 193662    2.9564  vmlinux          skb_release_data
> 177755    2.7136  vmlinux          ipt_do_table

You are probably benchmarking iptables/netfilter! How many rules do you
have?
