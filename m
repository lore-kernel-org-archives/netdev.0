From: Andy Fleming <afleming@freescale.com>
Subject: Re: RFC: PHY Abstraction Layer II
Date: Thu, 26 May 2005 13:45:20 -0500
Message-ID: <615E3662-7F4F-4277-A5F0-83086150F0FE@freescale.com>
References: <1107b64b01fb8e9a6c84359bb56881a6@freescale.com>
	<20050526113218.23e44164@dxpl.pdx.osdl.net>
Mime-Version: 1.0 (Apple Message framework v730)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@oss.sgi.com>,
	Embedded PPC Linux list <linuxppc-embedded@ozlabs.org>
Return-path: <linuxppc-embedded-bounces@ozlabs.org>
In-Reply-To: <20050526113218.23e44164@dxpl.pdx.osdl.net>
To: Stephen Hemminger <shemminger@osdl.org>
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-embedded>,
	<mailto:linuxppc-embedded-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-embedded>
List-Post: <mailto:linuxppc-embedded@ozlabs.org>
List-Help: <mailto:linuxppc-embedded-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-embedded>,
	<mailto:linuxppc-embedded-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-embedded-bounces@ozlabs.org
Errors-To: linuxppc-embedded-bounces@ozlabs.org
List-Id: netdev.vger.kernel.org


On May 26, 2005, at 13:32, Stephen Hemminger wrote:

> I finally got around to looking at this for the new skge driver.
> The Marvell phy code has several issues:
>     * hard coded hex values rather than constants

These are hard-coded because it's errata.  The errata doesn't name  
the registers, nor the bits being set, so the best I could do is  
something like:

phy_write(phydev, M88E1101_ERRATA_REGISTER1,  
M88E1101_ERRATA_REG1_VALUE1);

I'm not sure that's more useful.


>     * doesn't handle restricted autonegotiation

I'm not quite sure what you mean by this one.  ALL the PHYs support  
restricting auto-negotiation to certain values.  See drivers/net/phy/ 
phy_device.c:genphy_config_advert(), which is called by marvell's  
config_aneg function (eventually).

>     * it doesn't really help the driver that much there are too
>       many other warts in the hardware.

Err...  the skge hardware, or the Marvell hardware?  Could you  
specify some warts, so I can look into what changes might need to be  
made?

Andy
