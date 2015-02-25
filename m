From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next v4 0/3] Linn Ethernet Packet Sniffer driver
Date: Wed, 25 Feb 2015 18:30:53 +0100
Message-ID: <20150225173053.GE7703@localhost.localdomain>
References: <cover.1424796018.git.stathis.voukelatos@linn.co.uk>
 <20150225151945.GB7703@localhost.localdomain>
 <20150225170127.GD7703@localhost.localdomain>
 <54EE0268.2040201@linn.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	devicetree@vger.kernel.org
To: Stathis Voukelatos <stathis.voukelatos@linn.co.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <54EE0268.2040201@linn.co.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 25, 2015 at 05:12:08PM +0000, Stathis Voukelatos wrote:
> Regarding this last point, the actual counter that generates the
> timestamps is not part of the sniffer H/W module. Timestamps are
> provided to the sniffer externally in H/W by a different module.
> Apart of that there is not eg. a sniffer register to read the
> current counter value. I wonder if it should be the driver for the
> module where the counter belongs (called Event Timer in the
> Pistachio Soc) that should register the PHC.

It is okay to have the PHC come from another driver.  However, you do
need to export PHC index to the time stamping code, in order to
provide the 'phc_index' field for the ETHTOOL_GET_TS_INFO request.

You can also have one SW driver cover both HW modules, if that is
cleaner and easier.  Among all the other drivers, only gianfar has the
PHC separate.

> I need some more time to study your other suggestions regarding the
> PHY timestamping framework.

>From my (limited) understanding of your HW device, I should think that
it will work.  The PHY time stamping subsystem is not the most obvious
code in the world.  Please feel free to ask if you have any questions.

Thanks,
Richard
