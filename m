From: Jason McMullan <jason.mcmullan@timesys.com>
Subject: Re: [PATCH] MII bus API for PHY devices
Date: Thu, 18 Nov 2004 14:34:49 -0500
Message-ID: <1100806489.14467.47.camel@jmcmullan>
References: <069B6F33-341C-11D9-9652-000393DBC2E8@freescale.com>
	 <9B0D9272-398A-11D9-96F6-000393C30512@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Andy Fleming <afleming@freescale.com>
In-Reply-To: <9B0D9272-398A-11D9-96F6-000393C30512@freescale.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2004-11-18 at 11:52 -0600, Andy Fleming wrote:
> 1) How should we pass initialization information from the system to the 
> bus.  Information like which irq to use for each PHY, and what the 
> address space for the bus's controls is.  I would like to enforce 
> encapsulation so that the ethernet drivers don't need to know this 
> information, or pass it to the bus.

(Just an off-the-cuff answer here)

In line with the OCP->platform work I've been doing, I would think
that creating 'phy' devices on the platform bus would be appropriate,
with 'platform_data' that describes (a) the platform device ethernet
it's bus is on and (b) it's PHY ID on that bus. The PHY's IRQ would
be in it's platform resources.

> 2) How should we reflect the dependency of the ethernet driver on the 
> mii bus driver?

Hmm. Don't really know from a sysfs perspective...


> 3) How should we bind ethernet drivers to PHY drivers?

A PHY 'platform_data' struct like:

struct phy_device_data {
	struct {
		const char *name;
		int id;
	} ethernet_platform_device_parent;
	int	phy_id;
}
	
> Oh, and a 4th side-issue:
> Should each PHY have its own file? 

Actually, each PHY should have it's own device directory, like every
other device. Eventually, PHYs should have /dev/phy* entries, where
user-space can read/write PHY registers.

-- 
Jason McMullan <jason.mcmullan@timesys.com>
