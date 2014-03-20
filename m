From: Michal Kubecek <mkubecek@suse.cz>
Subject: Re: [PATCH net-next 2/2] bonding: support QinQ for bond arp interval
Date: Thu, 20 Mar 2014 09:24:15 +0100
Message-ID: <20140320082414.GA28839@unicorn.suse.cz>
References: <1395057975-19084-1-git-send-email-dingtianhong@huawei.com>
 <1395057975-19084-3-git-send-email-dingtianhong@huawei.com>
 <21958.1395078364@death.nxdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ding Tianhong <dingtianhong@huawei.com>, vfalico@redhat.com,
	andy@greyhouse.net, kaber@trash.net, davem@davemloft.net,
	netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:45236 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751129AbaCTIYQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Mar 2014 04:24:16 -0400
Content-Disposition: inline
In-Reply-To: <21958.1395078364@death.nxdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 17, 2014 at 10:46:04AM -0700, Jay Vosburgh wrote:
> Ding Tianhong <dingtianhong@huawei.com> wrote:
> >
> >ip link add link bond0  bond0.20 type vlan proto 802.1ad id 20
> >ip link add link bond0.20  bond0.20.200 type vlan proto 802.1q id 200
> 
> 	Is this nesting backwards?  The way I read it (and the way I
> recall that VLANs nest), "bond0.20" is the "regular" VLAN, i.e., if we
> just have bond0.20 it would be a standard 802.1q (ethertype 0x8100)
> VLAN.  Adding the second VLAN, .200 in this example, would be the second
> (outer) tag, and would be the 802.1ad (ethertype 0x88a8) tag.
> 
> 	In other words, adding a VLAN to an already existing VLAN makes
> the newly added VLAN the "outer" and the already existing VLAN the
> "inner."  Am I confused?

I don't think so. My understanding is that when sending a packet to
a vlan device, it is tagged (according to its "proto") and passed to its
underlying device.

So in the case above, sending a packet to bond0.20.200 would add an
802.1q tag and pass the result to bond0.20 which would add an 802.1ad
tag and pass the result to bond0. Which is the way it should work.

                                                       Michal Kubecek
