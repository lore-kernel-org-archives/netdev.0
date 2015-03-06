From: Stathis Voukelatos <stathis.voukelatos-zgcZaY4qg+21Qrn1Bg8BZw@public.gmane.org>
Subject: Re: [PATCH net-next v4 0/3] Linn Ethernet Packet Sniffer driver
Date: Fri, 6 Mar 2015 13:45:55 +0000
Message-ID: <54F9AF93.40908@linn.co.uk>
References: <cover.1424796018.git.stathis.voukelatos@linn.co.uk> <20150225151945.GB7703@localhost.localdomain> <20150225170127.GD7703@localhost.localdomain> <54EE0268.2040201@linn.co.uk> <20150225173053.GE7703@localhost.localdomain> <54F0A4C4.3020407@linn.co.uk> <20150227181447.GA11594@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
To: <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20150227181447.GA11594-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


Hi Richard,

On 27/02/15 18:14, Richard Cochran wrote:
 >> The H/W does have the capability to do that. However, in order to
 >> implement it there will be some architectural changes needed
 >> in the kernel. This module cannot really pretend to be a PHY.
 >> In the real world it sits between the MAC and the PHY.
 >
 > Right.
 >
 > Here is one idea.  Put a link to the TS device in the PHY's DT node.
 > Then, in phy_probe, check if the PHY's four methods, ts_info,
 > hwtstamp, rxtstamp, and txtstamp, are all null.  If so, check for a DT
 > link from the PHY's node to a TS device driver.  If found, then set
 > the four methods to call into the TS driver's callbacks.
 >
 > Just off of the top of my head.
 >

Thank you for your help and suggestions.

Although the PTP way appears to be the best from an architectural point
of view, we have some questions as whether it is suitable for the audio
use cases that this module is mainly intended for.
To use the PTP terminology in a large installation we would have a
potentially large number of clock domains.
It is not clear how to easily manage the creation and allocation of 
domains. In addition the clock will be pulled according to the audio
stream and it would be undesirable for other unrelated PTPv2 devices
on the network to join the clock domain and have their clocks 
synchronized to it.

The patch in its current form would allow a move to Linux using our
existing synchronization protocols (which are open-source). A move
to PTP is something to consider but will involve a fair amount of
redesign including upgrade of legacy products.


 > Thanks,
 > Richard
 >

Thank you,
Stathis
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
