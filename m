From: Dhananjay Phadke <dhananjay.phadke@qlogic.com>
Subject: Re: [BUG] netxen: Stops working between 2.6.30 and 2.6.31-rc1
Date: Fri, 20 Nov 2009 09:30:28 -0800
Message-ID: <4B06D234.4060600@qlogic.com>
References: <20091119163908.GJ14661@jayr.de>	<7608421F3572AB4292BB2532AE89D5658B0B95BD5C@AVEXMB1.qlogic.org>	<20091119183607.GK14661@jayr.de> <m1ocmyt2ly.fsf@fess.ebiederm.org>	<20091120075258.GM14661@jayr.de> <m1tywprvl4.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jens Rosenboom <me@jayr.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Amit Salecha <amit.salecha@qlogic.com>,
	Ameen Rahman <ameen.rahman@qlogic.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:39539 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753464AbZKTRbm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Nov 2009 12:31:42 -0500
In-Reply-To: <m1tywprvl4.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Weird. MSI's definitely weren't disabled.  Looking a little farther at
> your quoted setup MSI work on your board.  This is definitely
> something specific to the driver.  Except for a few initialization
> races that are an issue for bonding I am running 2.6.31 just fine.


Jens,

Even if /proc/interrupt says PCI-MSI in both cases, single interrupt 
case is msi vs. 4 vector case is msi-x. To confirm that msi-x doesn't 
work with your card/machine, you can still stay on 2.6.31 and set 
use_msi_x=0 in netxen_nic_main.c.

I had tried to make a available a module param to disable msi/msi-x for 
platforms where msi-x doesn't work cleanly, but it was declined by David 
Miller, et al.

Anyway, please note a few things -

Jens' has older generation (NX2031) of nic asic, so 4.0.xxx FW doesn't 
apply:

NetXen XGb XFP Board S/N IF72MK0200  Chip rev 0x25

Eric has newer generation (NX3031) of nic asic:

NetXen Dual XGb SFP+ LP Board S/N SF86BK0008  Chip rev 0x41


Anyhow, what I learned here is Jens obtained firmware from IBM Japan.
Could you please describe the source of your device, you should involve
respective OEM (HP/IBM) for getting right revision of the firmware.

If it was purchased via direct channel, call QLogic support about 
3.4.339 firmware. I can't imagine IBM Japan hosting firmware not 
released for IBM branded NIC boards.

Thanks,
Dhananjay

