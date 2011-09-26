From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Bridge stays down until a port is added
Date: Mon, 26 Sep 2011 08:47:43 -0700
Message-ID: <20110926084743.35cb2ccc@nehalam.linuxnetplumber.net>
References: <20110811070659.GA21307@torres.zugschlus.de>
	<20110811081706.7307e8b2@nehalam.ftrdhcpuser.net>
	<20110917204257.GA2636@torres.zugschlus.de>
	<1316550027.1783.102.camel@dcbw.foobar.com>
	<20110925082504.GA32712@torres.zugschlus.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Marc Haber <mh+netdev@zugschlus.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:40548 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750928Ab1IZPrp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Sep 2011 11:47:45 -0400
In-Reply-To: <20110925082504.GA32712@torres.zugschlus.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The root of this whole problem is really that IPv6 reports addresses
in a tentative state to applications that can not be passed to the bind() system call.
For most cases, this problem never happens because the tentative addresses are
resolved by Duplicate Address Detection before the application starts. But
I have seen (and fixed) this happen before this whole discussion started.

1. The problem is not unique to bridges. It happens with bridge, macvtap, 
   even on wireless networks where the device is available but carrier is
   not asserted.

2. Any change to what the kernel does (like not reporting tentative addresses)
   would break applications even worse.

3. When the bridge was always reporting carrier, it was in effect breaking
   IPv6 Duplicate Address Detection. And that is bad. 
