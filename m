From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: Re: 3.0.0rc6: ethtool not working without a cable
Date: Wed, 20 Jul 2011 10:53:23 -0700 (Pacific Daylight Time)
Message-ID: <alpine.WNT.2.00.1107201050450.1084@JBRANDEB-DESK2.amr.corp.intel.com>
References: <201107061338.08573.a.miskiewicz@gmail.com> <1309962484.4280.25.camel@localhost> <201107061653.04689.a.miskiewicz@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:34998 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751997Ab1GTRxa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jul 2011 13:53:30 -0400
In-Reply-To: <201107061653.04689.a.miskiewicz@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Wed, 6 Jul 2011, Arkadiusz Miskiewicz wrote:

> On Wednesday 06 of July 2011, Ben Hutchings wrote:
> > > If there is no cable then ethtool reports no device. It wasn't that
> > > before AFAIK.
> > > 
> > > ethtool version 2.6.36
> > > 
> > > 
> > > cable disconnected:
> > > 
> > > [root@t400 ~]# ethtool eth0
> > > Settings for eth0:
> > > Cannot get device settings: No such device
> > > Cannot get wake-on-lan settings: No such device
> > > Cannot get message level: No such device
> > > Cannot get link status: No such device
> > > No data available
> > > zsh: exit 75    ethtool eth0
> > > [root@t400 ~]# ethtool -i eth0
> > > Cannot get driver information: No such device
> > > zsh: exit 71    ethtool -i eth0

please check lspci -vvv on your device when cable is unplugged.  I'm 
wondering if OSPM (os power management) is kicking in (if enabled in your 
kernel) and somehow interacting badly with ethtool.

if the device is in D3, then most ethtool stuff won't work, since all the 
registers in the device (except in config space) don't work when in D3.
