From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Subject: RE: [Intel-wired-lan] [V2 PATCH 1/1] ixgbe: force to synchronize
 reporting "link on" and
Date: Thu, 24 Dec 2015 06:17:34 +0000
Message-ID: <87618083B2453E4A8714035B62D67992504EC996@FMSMSX105.amr.corp.intel.com>
References: <1450868046.3316.11.camel@intel.com>
 <1450926752-11392-1-git-send-email-zyjzyj2000@gmail.com>
 <567B7E61.3070207@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Viswanathan, Ven (Wind River)" <venkat.viswanathan@windriver.com>,
	"Shteinbock, Boris (Wind River)" <boris.shteinbock@windriver.com>,
	"Bourg, Vincent (Wind River)" <vincent.bourg@windriver.com>
To: zhuyj <zyjzyj2000@gmail.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Nelson, Shannon" <shannon.nelson@intel.com>,
	"Wyborny, Carolyn" <carolyn.wyborny@intel.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"Williams, Mitch A" <mitch.a.williams@intel.com>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:45127 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932251AbbLXGRg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Dec 2015 01:17:36 -0500
In-Reply-To: <567B7E61.3070207@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: Intel-wired-lan [mailto:intel-wired-lan-bounces@lists.osuosl.org] On
>Behalf Of zhuyj
>Sent: Wednesday, December 23, 2015 9:11 PM
>To: Kirsher, Jeffrey T; Brandeburg, Jesse; Nelson, Shannon; Wyborny,
>Carolyn; Skidmore, Donald C; Allan, Bruce W; Ronciak, John; Williams, Mitch
>A; intel-wired-lan@lists.osuosl.org; netdev@vger.kernel.org; e1000-
>devel@lists.sourceforge.net
>Cc: Viswanathan, Ven (Wind River); Shteinbock, Boris (Wind River); Bourg,
>Vincent (Wind River)
>Subject: Re: [Intel-wired-lan] [V2 PATCH 1/1] ixgbe: force to synchronize
>reporting "link on" and
>
>On 12/24/2015 11:12 AM, zyjzyj2000@gmail.com <mailto:zyjzyj2000@gmail.com>
>wrote:
>
>
>
>	Hi, Jeff
>
>	Thanks for your reply.
>
>	Changes:
>	Since there is a time span between link_up and link_speed to X540
>NIC, it is not appropriate to continue in the function
>ixgbe_watchdog_link_is_up if only link_up is ready.
>
>	Best Regards!
>	Zhu Yanjun
>	--
>	To unsubscribe from this list: send the line "unsubscribe netdev" in
>	the body of a message to majordomo@vger.kernel.org
><mailto:majordomo@vger.kernel.org>
>	More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>
>Hi, Jeff
>
>The following logs are from the customer.  From these logs, there is a time
>span between link_up and link_speed.
>This time span sometimes will make bonding in 802.3ad mode not work well.
>
>What I have done in the patch is to prevent this time span in the ixgbe
>driver.
>
>Best Regards!
>Zhu Yanjun
>
>Settings for eth0:
>    Supported ports: [ TP ]
>    Supported link modes:   100baseT/Full
>                            1000baseT/Full
>                            10000baseT/Full
>    Supported pause frame use: No
>    Supports auto-negotiation: Yes
>    Advertised link modes:  100baseT/Full
>                            1000baseT/Full
>                            10000baseT/Full
>    Advertised pause frame use: No
>    Advertised auto-negotiation: Yes
>    Speed: Unknown!
>    Duplex: Unknown! (255)
>    Port: Twisted Pair
>    PHYAD: 0
>    Transceiver: external
>    Auto-negotiation: on
>    MDI-X: Unknown
>    Supports Wake-on: d
>    Wake-on: d
>    Current message level: 0x00000007 (7)
>                   drv probe link
>    Link detected: no
>Settings for eth0:
>    Supported ports: [ TP ]
>    Supported link modes:   100baseT/Full
>                            1000baseT/Full
>                            10000baseT/Full
>    Supported pause frame use: No
>    Supports auto-negotiation: Yes
>    Advertised link modes:  100baseT/Full
>                            1000baseT/Full
>                            10000baseT/Full
>    Advertised pause frame use: No
>    Advertised auto-negotiation: Yes
>    Speed: Unknown!
>    Duplex: Unknown! (255)
>    Port: Twisted Pair
>    PHYAD: 0
>    Transceiver: external
>    Auto-negotiation: on
>    MDI-X: Unknown
>    Supports Wake-on: d
>    Wake-on: d
>    Current message level: 0x00000007 (7)
>                   drv probe link
>    Link detected: yes
>Settings for eth0:
>    Supported ports: [ TP ]
>    Supported link modes:   100baseT/Full
>                            1000baseT/Full
>                            10000baseT/Full
>    Supported pause frame use: No
>    Supports auto-negotiation: Yes
>    Advertised link modes:  100baseT/Full
>                            1000baseT/Full
>                            10000baseT/Full
>    Advertised pause frame use: No
>    Advertised auto-negotiation: Yes
>    Speed: Unknown!
>    Duplex: Unknown! (255)
>    Port: Twisted Pair
>    PHYAD: 0
>    Transceiver: external
>    Auto-negotiation: on
>    MDI-X: Unknown
>    Supports Wake-on: d
>    Wake-on: d
>    Current message level: 0x00000007 (7)
>                   drv probe link
>    Link detected: yes
>Settings for eth0:
>    Supported ports: [ TP ]
>    Supported link modes:   100baseT/Full
>                            1000baseT/Full
>                            10000baseT/Full
>    Supported pause frame use: No
>    Supports auto-negotiation: Yes
>    Advertised link modes:  100baseT/Full
>                            1000baseT/Full
>                            10000baseT/Full
>    Advertised pause frame use: No
>    Advertised auto-negotiation: Yes
>    Speed: Unknown!
>    Duplex: Unknown! (255)
>    Port: Twisted Pair
>    PHYAD: 0
>    Transceiver: external
>    Auto-negotiation: on
>    MDI-X: Unknown
>    Supports Wake-on: d
>    Wake-on: d
>    Current message level: 0x00000007 (7)
>                   drv probe link
>    Link detected: yes
>Settings for eth0:
>    Supported ports: [ TP ]
>    Supported link modes:   100baseT/Full
>                            1000baseT/Full
>                            10000baseT/Full
>    Supported pause frame use: No
>    Supports auto-negotiation: Yes
>    Advertised link modes:  100baseT/Full
>                            1000baseT/Full
>                            10000baseT/Full
>    Advertised pause frame use: No
>    Advertised auto-negotiation: Yes
>    Speed: Unknown!
>    Duplex: Unknown! (255)
>    Port: Twisted Pair
>    PHYAD: 0
>    Transceiver: external
>    Auto-negotiation: on
>    MDI-X: Unknown
>    Supports Wake-on: d
>    Wake-on: d
>    Current message level: 0x00000007 (7)
>                   drv probe link
>    Link detected: yes
>Settings for eth0:
>    Supported ports: [ TP ]
>    Supported link modes:   100baseT/Full
>                            1000baseT/Full
>                            10000baseT/Full
>    Supported pause frame use: No
>    Supports auto-negotiation: Yes
>    Advertised link modes:  100baseT/Full
>                            1000baseT/Full
>                            10000baseT/Full
>    Advertised pause frame use: No
>    Advertised auto-negotiation: Yes
>    Speed: 10000Mb/s
>    Duplex: Full
>    Port: Twisted Pair
>    PHYAD: 0
>    Transceiver: external
>    Auto-negotiation: on
>    MDI-X: Unknown
>    Supports Wake-on: d
>    Wake-on: d
>    Current message level: 0x00000007 (7)
>                   drv probe link
>    Link detected: yes

Can you provide the related dmesg output? 
What did the driver report in the "Link Up" messages?

Thanks,
Emil
