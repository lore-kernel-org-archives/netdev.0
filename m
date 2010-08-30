From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [rfc] Merging the Open vSwitch datapath
Date: Mon, 30 Aug 2010 23:04:37 +0200
Message-ID: <201008302304.38061.arnd@arndb.de>
References: <20100830062755.GA22396@verge.net.au> <20100830183328.GI7629@nicira.com> <43F901BD926A4E43B106BF17856F0755F63A092B@orsmsx508.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Ben Pfaff <blp@nicira.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jesse Gross <jesse@nicira.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Chris Wright <chrisw@sous-sol.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>
To: "Rose, Gregory V" <gregory.v.rose@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.171]:49166 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753346Ab0H3VFH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Aug 2010 17:05:07 -0400
In-Reply-To: <43F901BD926A4E43B106BF17856F0755F63A092B@orsmsx508.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 30 August 2010 20:45:19 Rose, Gregory V wrote:
> As of now there are no existing ways to get switch configuration to a
> NIC without resorting to a customized interface such as a private IOCTL.

Well, there are the IFLA_VF_INFO netlink attributes that I would
assume are to be used for switch configuration and extended where
required for that, e.g. to set VEPA mode per channel.

> EVB is an emerging standard that I think would be desirable to support
> in the kernel.

Do you mean 802.1Qbg? Why would you want kernel support? There is
already support for VEPA in the kernel, and 802.1ad provider bridges
should probably be added in order to support multi-channel setups.

The other parts are configuration protocols like LLDP and CDP, which
we normally do in user space (e.g. lldpad).

What else is there that you think should go into the kernel.

> As you mention netlink is easier to extend and I think
> it would be a great way to add support for NIC EVB in the kernel. 
> But even with a kernel interface there is still no user level tool.

Using the same interface as Open vSwitch would be really nice to
configure a NIC bridge sounds interesting if we want to speed up
Open vSwitch, but I don't think it makes any sense for the EVB
protocols. Quite the contrary, you typically want the NIC to
get out of the way and do all the bridging in the external
switch in case of VEPA. Or you actually want to use features of
the software bridge implementation like iptables.

One idea that we have discussed in the past is to use the macvlan
netlink interface to create ports inside a NIC. This interface
already exists in the kernel, and it allows both bridged and VEPA
interfaces. The main advantage of this is that the kernel can
transparently create ports either using software macvlan or
hardware accelerated functions where available.

	Arnd
