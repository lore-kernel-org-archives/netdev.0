From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH -rt DO NOT APPLY] Fix for tg3 networking lockup
Date: Thu, 3 Aug 2006 20:45:31 -0700
Message-ID: <1551EAE59135BE47B544934E30FC4FC093FA11@NT-IRVA-0751.brcm.ad.broadcom.com>
References: <20060804032348.GA16313@thunk.org>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "David Miller" <davem@davemloft.net>, herbert@gondor.apana.org.au,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:37642 "EHLO
	mms1.broadcom.com") by vger.kernel.org with ESMTP id S1030240AbWHDDpo convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Aug 2006 23:45:44 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20060804032348.GA16313@thunk.org>
To: "Theodore Tso" <tytso@mit.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Theodore Tso wrote:

> Parden me for asking a dumb question, but what's being accomplished by
> resetting the chip if the system has crashed?  Why not reset the chip
> when the system reboots and it sees the PCI bus reset?  I guess I'm
> missing the purpose of the ASF heartbeat; why does the networking chip
> need a chip-specific watchdog?
> 

ASF is firmware that monitors the system and sends out alerts whenever
certain events happen.  So it needs to run before the OS boots or after
it has crashed.  When the driver is up and running, the driver and ASF
run independently sending and receiving traffic on the same wire.  Of
course, the bandwidth that is used by ASF is a very tiny fraction of the
host traffic.  If the system crashes, the FIFO and other resources on
the NIC will be backed up and ASF can no longer function without
resetting
the chip.

As David explained, ASF is only used on servers.

