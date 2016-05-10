From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: RE: bnx2x in 4.6rc7 with FW 7.13.1.0 not present
Date: Tue, 10 May 2016 05:22:38 +0000
Message-ID: <CO2PR11MB00888D5DCAE2265A06BFB07597710@CO2PR11MB0088.namprd11.prod.outlook.com>
References: <94D0CD8314A33A4D9D801C0FE68B4029639613DA@G4W3202.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Ariel Elior <Ariel.Elior@qlogic.com>,
	"David Miller" <davem@davemloft.net>
To: "Elliott, Robert (Persistent Memory)" <elliott@hpe.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1on0115.outbound.protection.outlook.com ([157.56.110.115]:16288
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751249AbcEJFhu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2016 01:37:50 -0400
In-Reply-To: <94D0CD8314A33A4D9D801C0FE68B4029639613DA@G4W3202.americas.hpqcorp.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Upgrading a system from kernel 4.2 to 4.6rc7, there is an extra 2 minute delay
> while booting due to these problems:
> 
>     [   47.977221] bnx2x 0000:04:00.1: Direct firmware load for bnx2x/bnx2x-e2-
> 7.13.1.0.fw failed with error -2
... 
> Could the driver fall back to an older firmware version more gracefully?

No.

The internal FW isn't necessarily backward compatible [there are some
Compatibility in fastpath in order to support VFs, but not in general].
Doing what you ask would means filling the driver with a lot of legacy code
for older FWs, adding per-FW version HSI files, etc.

So in short - if you've installed a fresh kernel on top of an existing distro
that lacked the latest firmware in its filesystem, getting that missing 
.bin file from linux-firmware is the way to go.

Cheers,
Yuval
