From: Vasu Dev <vasu.dev@linux.intel.com>
Subject: Re: [net-next-2.6 PATCH 1/3] vlan: adds vlan_dev_select_queue
Date: Thu, 18 Feb 2010 17:12:50 -0800
Message-ID: <1266541970.1891.109.camel@vi2.jf.intel.com>
References: <20100217123606.18210.13602.stgit@localhost.localdomain>
	 <1266414675.3246.12.camel@edumazet-laptop>
	 <20100217.134330.48386140.davem@davemloft.net>
	 <1266446441.1891.96.camel@vi2.jf.intel.com>
	 <1266478630.2877.9.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org, gospo@redhat.com, vasu.dev@intel.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.89]:48048 "EHLO
	fmsmga101.fm.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752788Ab0BSBMv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2010 20:12:51 -0500
In-Reply-To: <1266478630.2877.9.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-02-18 at 08:37 +0100, Eric Dumazet wrote:
> > This means vlan_netdev_ops & vlan_netdev_accel_ops not to be const
> > anymore so that vlan_dev_select_queue() could be initialized to vlan
> ops
> > based on real dev ndo_select_queue() present or not, should be okay
> to
> > be not const anymore. I'll update patch as suggested.
> 
> No they should stay const
> 
> I said you should mirror (copy if you prefer) the structure, one with
> a
> NULL ndo_select_queue pointer, one with a ndo_select_queue =
> vlan_dev_select_queue.
> 
> Both structures are const.
> 
> You must not dynamiucally change the structure, because the same
> machine
> might have a vlan over a device with no ndo_select_queue() method, and
> another vlan over a device with a ndo_select_queue()
> 

I see, I'll mirror existing vlan op structs to have them w/ and w/o
vlan_dev_select_queue while having all vlan ops statically defined
const.

	Thanks Eric.
	Vasu

