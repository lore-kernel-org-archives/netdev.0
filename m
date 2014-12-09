From: Chris Conley <cconley@phytec.com>
Subject: smsc911x: loopback test causing oops
Date: Tue, 9 Dec 2014 19:33:34 +0000
Message-ID: <BLUPR08MB5019A04480788B3FA1D5451D7650@BLUPR08MB501.namprd08.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0073.outbound.protection.outlook.com ([65.55.169.73]:14112
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752360AbaLIUGe convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2014 15:06:34 -0500
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello all,

I'm trying to find out what the USE_PHY_WORK_AROUND ifdef is for.  I looked in the git logs and this workaround was introduced with the initial checkin of the driver files, and not explained.  

What was the hardware problem it was meant to handle? And is it valid for only certain chips? (i.e. the SMSC9221I, which is what we're using on this platform).

We are seeing the loopback test fail w/ invalid packet size, and at some point during the loopback test after that, we get a kernel oops for invalid address.  And the address is very invalid (e.g. 48fa0569, fa65a8c4).  We were seeing this and another problem with irq_spinlocks after the probe returned for the 2nd instance of the phy, but that was fixed by backporting the current 3.18 driver to the linux-fslc_3.14.14 kernel.  Initially it looked like the backport fixed all of the problems, but one remained after over the weekend testing.  If the platform is direct-connect plugged into another platform, the oops happens in loopback again.

The driver seems fine w/ the loopback disabled (no data xfer problems, etc), but I wanted to find out why it was there in the first place before forcing it off in a production environment.

Thanks,

//Chris
