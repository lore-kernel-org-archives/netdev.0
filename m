From: "Rose, Gregory V" <gregory.v.rose@intel.com>
Subject: RE: [rfc] Merging the Open vSwitch datapath
Date: Mon, 30 Aug 2010 15:15:25 -0700
Message-ID: <43F901BD926A4E43B106BF17856F0755F63A0B62@orsmsx508.amr.corp.intel.com>
References: <20100830062755.GA22396@verge.net.au>
 <20100830183328.GI7629@nicira.com>
 <43F901BD926A4E43B106BF17856F0755F63A092B@orsmsx508.amr.corp.intel.com>
 <201008302304.38061.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Ben Pfaff <blp@nicira.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jesse Gross <jesse@nicira.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Chris Wright <chrisw@sous-sol.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:42546 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752486Ab0H3WPt convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Aug 2010 18:15:49 -0400
In-Reply-To: <201008302304.38061.arnd@arndb.de>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
>On Behalf Of Arnd Bergmann
>Sent: Monday, August 30, 2010 2:05 PM
>To: Rose, Gregory V
>Cc: Ben Pfaff; netdev@vger.kernel.org; Jesse Gross; Stephen Hemminger;
>Chris Wright; Herbert Xu; David Miller
>Subject: Re: [rfc] Merging the Open vSwitch datapath
>
>On Monday 30 August 2010 20:45:19 Rose, Gregory V wrote:
>> As of now there are no existing ways to get switch configuration to a
>> NIC without resorting to a customized interface such as a private
>IOCTL.
>
>Well, there are the IFLA_VF_INFO netlink attributes that I would
>assume are to be used for switch configuration and extended where
>required for that, e.g. to set VEPA mode per channel.
>
>> EVB is an emerging standard that I think would be desirable to support
>> in the kernel.
>
>Do you mean 802.1Qbg?

Yes, and 802.1Qbh.

 Why would you want kernel support? There is
>already support for VEPA in the kernel, and 802.1ad provider bridges
>should probably be added in order to support multi-channel setups.

I should probably read up a bit more on 802.1ad.

>
>The other parts are configuration protocols like LLDP and CDP, which
>we normally do in user space (e.g. lldpad).
>
>What else is there that you think should go into the kernel.

It seems to me that the IFLA_VF_INFO netlink attributes are station oriented.  The kernel support I see there is insufficient for some other things that need to be done for access control, forwarding rules and actions taken on certain kind of packets.  I think there'll be a need to configure the switch itself, not just the stations attached to the switch.

>
>> As you mention netlink is easier to extend and I think
>> it would be a great way to add support for NIC EVB in the kernel.
>> But even with a kernel interface there is still no user level tool.
>
>Using the same interface as Open vSwitch would be really nice to
>configure a NIC bridge sounds interesting if we want to speed up
>Open vSwitch, but I don't think it makes any sense for the EVB
>protocols. Quite the contrary, you typically want the NIC to
>get out of the way and do all the bridging in the external
>switch in case of VEPA. Or you actually want to use features of
>the software bridge implementation like iptables.

What if the NIC is the external switch?  I mean, what if the NIC has an edge virtual bridge embedded in it?  The IFLA_VF_INFO messages are sufficient for many features but there are some that it doesn't address.  And I don't know of any way to get iptables rules down to the VF using existing kernel interfaces.  Perhaps I missed something.

>
>One idea that we have discussed in the past is to use the macvlan
>netlink interface to create ports inside a NIC. This interface
>already exists in the kernel, and it allows both bridged and VEPA
>interfaces. The main advantage of this is that the kernel can
>transparently create ports either using software macvlan or
>hardware accelerated functions where available.

This actually sounds like a good idea.  I hadn't thought about that.  It would cover one of the primary issues I'm dealing with right now.

- Greg

