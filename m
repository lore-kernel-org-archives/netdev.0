From: Ben Hutchings <bhutchings@solarflare.com>
Subject: RE: [PATCH v2] net: add new QCA alx ethernet driver
Date: Thu, 23 Aug 2012 22:09:02 +0100
Message-ID: <1345756142.2579.16.camel@bwh-desktop.uk.solarflarecom.com>
References: <1345480949-14800-1-git-send-email-cjren@qca.qualcomm.com>
	 <20120822.225700.714020017287504609.davem@davemloft.net>
	 <157393863283F442885425D2C45428562A4F5169@nasanexd02f.na.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"Ren, Cloud" <cjren@qca.qualcomm.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	qca-linux-team <qca-linux-team@qualcomm.com>,
	nic-devel <nic-devel@qualcomm.com>,
	"Rodriguez, Luis" <rodrigue@qca.qualcomm.com>
To: "Huang, Xiong" <xiong@qca.qualcomm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <157393863283F442885425D2C45428562A4F5169@nasanexd02f.na.qualcomm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2012-08-23 at 06:35 +0000, Huang, Xiong wrote:
> > This is why we require that portable, sane, interfaces are added to ethtool for
> > driver diagnostics.  That way users can perform a task in the same way
> > regardless of what hardware and driver are underneath.
> 
> I quite agree you on using ethtool to implement it. we did consider it. 
> But ethtool has some limitation, for example, the NIC has built-in OTP (TWSI interface)
> And Flash (External SPI interface),  their properties are quite different with EEPROM which
> Ethtool supports.
> To support such memory (OTP/Flash), we need additional input parameters.

You have two reasonable options for this:
1. The ETHTOOL_FLASHDEV command takes a partition ID and filename to
write.  The driver is supposed to load the file through the firmware
loader and then rewrite the partition completely (erasing if necessary).
Example: be2net.
2. For a more flexible interface, implement an MTD driver as part of
your net driver.  Example: sfc.

> Same situation exists in diagnostic utility. Ethtool only provide two options : offline & online
> That's too gross to locate which part/module of the chip is malfunction. we also need 
> more options to detect it.

That's absolute nonsense, you can run as many sub-tests as you want and
provide separate results for each of them.

Ben.

> that's why we finally selected a custom debugfs interface. 

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
