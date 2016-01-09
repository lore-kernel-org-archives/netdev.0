From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Subject: RE: [RFC PATCH net-next] bonding: Use notifiers for slave link
 state detection
Date: Sat, 9 Jan 2016 01:35:27 +0000
Message-ID: <87618083B2453E4A8714035B62D6799250505491@FMSMSX105.amr.corp.intel.com>
References: <87618083B2453E4A8714035B62D6799250504549@FMSMSX105.amr.corp.intel.com>
 <1452147313-22886-1-git-send-email-zyjzyj2000@gmail.com>
 <16587.1452148421@famine> <27321.1452216515@famine>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "mkubecek@suse.cz" <mkubecek@suse.cz>,
	"vfalico@gmail.com" <vfalico@gmail.com>,
	"gospo@cumulusnetworks.com" <gospo@cumulusnetworks.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Shteinbock, Boris (Wind River)" <boris.shteinbock@windriver.com>
To: Jay Vosburgh <jay.vosburgh@canonical.com>,
	"zyjzyj2000@gmail.com" <zyjzyj2000@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:29117 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754765AbcAIBf3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jan 2016 20:35:29 -0500
In-Reply-To: <27321.1452216515@famine>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: Jay Vosburgh [mailto:jay.vosburgh@canonical.com]
>Sent: Thursday, January 07, 2016 5:29 PM
>Subject: [RFC PATCH net-next] bonding: Use notifiers for slave link state
>detection
>
>
>	TEST PATCH
>
>	This patch modifies bonding to utilize notifier callbacks to
>detect slave link state changes.  It is intended to be used with miimon
>set to zero, and does not support the updelay or downdelay options to
>bonding.  It's not as complicated as it looks; most of the change set is
>to break out the inner loop of bond_miimon_inspect into its own
>function.

Jay,
 
I managed to do a quick test with this patch and occasionally there is a case where
I see the bonding driver reporting link up for an interface (eth1) that is not up just yet:

[12972.741999] bonding: bond0 is being created...
[12972.761907] bond0: Setting xmit hash policy to layer3+4 (1)
[12972.761990] bond0: Setting MII monitoring interval to 0
[12972.767131] bond0: Setting LACP rate to fast (1)
[12972.767916] IPv6: ADDRCONF(NETDEV_UP): bond0: link is not ready
[12972.846158] bond0: Adding slave eth0
[12972.950548] pps pps0: new PPS source ptp0
[12972.950555] ixgbe 0000:01:00.0: registered PHC device on eth0
[12973.071750] IPv6: ADDRCONF(NETDEV_UP): eth0: link is not ready
[12973.072023] bond0: Enslaving eth0 as a backup interface with an up link
[12974.122295] bond0: Adding slave eth1
[12974.227639] pps pps1: new PPS source ptp1
[12974.227645] ixgbe 0000:01:00.1: registered PHC device on eth1
[12974.349306] IPv6: ADDRCONF(NETDEV_UP): eth1: link is not ready
[12974.349584] bond0: Enslaving eth1 as a backup interface with an up link
[12982.982797] ixgbe 0000:01:00.0 eth0: NIC Link is Up 10 Gbps, Flow Control: RX/TX
[12983.068437] IPv6: ADDRCONF(NETDEV_CHANGE): bond0: link becomes ready
[12983.185720] ixgbe 0000:01:00.0 eth0: NIC Link is Down
[12983.982454] ixgbe 0000:01:00.0 eth0: speed changed to 0 for port eth0
[12983.982539] bond0: link status definitely down for interface eth0, disabling it
[12983.982546] bond0: link status definitely up for interface eth1, 0 Mbps full duplex
[12983.982550] bond0: first active interface up!
[12985.213752] ixgbe 0000:01:00.0 eth0: NIC Link is Up 10 Gbps, Flow Control: RX/TX
[12985.213970] bond0: link status definitely up for interface eth0, 10000 Mbps full duplex
[12985.213975] bond0: link status definitely up for interface eth1, 0 Mbps full duplex
[12989.195157] ixgbe 0000:01:00.1 eth1: NIC Link is Up 10 Gbps, Flow Control: RX/TX

Thanks,
Emil
