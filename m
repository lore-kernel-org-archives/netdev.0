From: Alexander Graf <agraf@suse.de>
Subject: Re: [PATCH] phy dp83867: depend on CONFIG_OF_MDIO
Date: Mon, 16 May 2016 19:59:26 +0200
Message-ID: <6b92e909-6d2f-6ff0-8e1b-eb0c3f8c2dcd@suse.de>
References: <1463398095-123269-1-git-send-email-agraf@suse.de>
 <20160516124444.GB27725@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	michal.simek@xilinx.com, Dan Murphy <dmurphy@ti.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160516124444.GB27725@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 16.05.16 14:44, Andrew Lunn wrote:
> On Mon, May 16, 2016 at 01:28:15PM +0200, Alexander Graf wrote:
>> The DP83867 phy driver doesn't actually work when CONFIG_OF_MDIO isn't enabled.
>> It simply passes the device tree test, but leaves all internal configuration
>> initialized at 0. Then it configures the phy with those values and renders a
>> previously working configuration useless.
>>
>> This patch makes sure that we only build the DP83867 phy code when
>> CONFIG_OF_MDIO is set, to not run into that problem.
> 
> Hi Alexander
> 
> Looking at the code, the parameters read from device tree are needed
> for RGMII mode. What about the case the PHY is used not in RGMII mode?
> Could it be there are device trees which legitimately don't have these
> properties since they are not needed, and are now going to get
> -ENODEV?

To be honest, I don't know. I only stumbled over this because we compile
all those phy drivers as modules and the driver simply rendered one
system I was working on unusable wrt network.

Dan?


Alex
