From: Kevin Smith <kevin.smith@elecsyscorp.com>
Subject: Re: [PATCH net] net: dsa: mv88e6xxx: fix port VLAN maps
Date: Fri, 29 Jan 2016 15:14:59 +0000
Message-ID: <56AB81F4.6050409@elecsyscorp.com>
References: <1454018077-11222-1-git-send-email-vivien.didelot@savoirfairelinux.com>
 <20160129021832.GA12692@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"kernel@savoirfairelinux.com" <kernel@savoirfairelinux.com>,
	"David S. Miller" <davem@davemloft.net>,
	Russell King <rmk+kernel@arm.linux.org.uk>
To: Andrew Lunn <andrew@lunn.ch>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s12p02o147.mxlogic.net ([208.65.145.70]:42929 "EHLO
	s12p02o147.mxlogic.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752311AbcA2PYQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jan 2016 10:24:16 -0500
In-Reply-To: <20160129021832.GA12692@lunn.ch>
Content-Language: en-US
Content-ID: <1AD3B5D749F08E4B9566AE85D7217024@dciincorporated.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/28/2016 08:18 PM, Andrew Lunn wrote:
> On Thu, Jan 28, 2016 at 04:54:37PM -0500, Vivien Didelot wrote:
>> Currently the port based VLAN maps should be configured to allow every
>> port to egress frames on all other ports, except themselves.
>>
>> The debugfs interface shows that they are misconfigured. For instance, a
>> 7-port switch has the following content in the related register 0x06:
>>
>>         GLOBAL GLOBAL2 SERDES   0    1    2    3    4    5    6
>>      ...
>>      6:  1fa4    1f0f       4   7f   7e   7d   7c   7b   7a   79
>>      ...
>>
>> This means that port 3 is allowed to talk to port 2-6, but cannot talk
>> to ports 0 and 1. With this fix, port 3 can correctly talk to all ports
>> except 3 itself:
>>
>>         GLOBAL GLOBAL2 SERDES   0    1    2    3    4    5    6
>>      ...
>>      6:  1fa4    1f0f       4   7e   7d   7b   77   6f   5f   3f
>>      ...
>>
>> Fixes: ede8098d0fef ("net: dsa: mv88e6xxx: bridges do not need an FID")
>> Reported-by: Kevin Smith <kevin.smith@elecsyscorp.com>
>> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
> Reviewed-by: Andrew Lunn <andrew@lunn.ch>
Tested-by: Kevin Smith <kevin.smith@elecsyscorp.com>
