From: Naoto MATSUMOTO <n-matsumoto@sakura.ad.jp>
Subject: Re[2]: [PATCH V2 09/12] net/eipoib: Add main driver functionality
Date: Tue, 07 Aug 2012 10:21:33 +0900
Message-ID: <20120807102129.5C95.C42C3789@sakura.ad.jp>
References: <50205DE0.7080706@mellanox.com> <87obmnfs4p.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: Ali Ayoub <ali@mellanox.com>, David Miller <davem@davemloft.net>,
	ogerlitz@mellanox.com, roland@kernel.org, netdev@vger.kernel.org,
	sean.hefty@intel.com, erezsh@mellanox.co.il, dledford@redhat.com
To: ebiederm@xmission.com (Eric W. Biederman)
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.sakura.ad.jp ([210.224.172.11]:42670 "EHLO
	mail.sakura.ad.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756869Ab2HGBYl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Aug 2012 21:24:41 -0400
In-Reply-To: <87obmnfs4p.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi Eric, Ali

On Mon, 06 Aug 2012 17:44:06 -0700
ebiederm@xmission.com (Eric W. Biederman) wrote:

> Implementations involving bridges like macvlan and macvtap are
> performance optimizations, and the optimizations don't even apply in
> areas like 802.11, where only one mac address is supported per adapter.

We had nearly equal situation perfomance result. share for you.

-----------------------------------------------------------------------
Ethernet over EoIB using gretap with "Raid STP" performance result.
http://twitpic.com/agd1pp

How to use EoIB with gretap. 
http://twitpic.com/agd4io


ifconfig ib0 10.1.1.1/24 up 
ip link add eoib0 type gretap remote 10.1.1.2 local 10.1.1.1
ip link add eoib1 type gretap remote 10.1.1.3 local 10.1.1.1
ip link add type veth
ifconfig eoib0 up up
ifconfig eoib1 up up
ifconfig veth0 up up
ifconfig veth1 up up

brctl addbr br0
brctl addif br0 eoib0
brctl addif br0 eoib1
bcrtl addif br0 veth1

rstpd
rstpctl rstp br0 on
rstpctl setbridgeprio br0 40960
rstpctl setportpathcost br0 vpn1 40000
rstpctl sethello br0 1
rstpctl setmaxage br0 6
rstpctl setfdelay br0 4
brctl stp br0 on
brctl sethello br0 1
brctl setfd br0 4
brctl setmaxage br0 6
-----------------------------------------------------------------------

regards,

-- 
SAKURA Internet Inc. / Senior Researcher
Naoto MATSUMOTO <n-matsumoto@sakura.ad.jp>
SAKURA Research Center <http://research.sakura.ad.jp/>
