From: Jamal Hadi Salim <hadi@cyberus.ca>
Subject: Re: r8169 driver problem with RTL8110SB chip (on iop3xx ARM board)
Date: Fri, 28 Jul 2006 08:28:14 -0400
Message-ID: <1154089694.5165.54.camel@jzny2>
References: <20060728101109.GA25854@xi.wantstofly.org>
	 <20060728104946.GA6710@electric-eye.fr.zoreil.com>
	 <20060728111534.GD25854@xi.wantstofly.org>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org,
	tbm@cyrius.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx02.cybersurf.com ([209.197.145.105]:12179 "EHLO
	mx02.cybersurf.com") by vger.kernel.org with ESMTP id S1161136AbWG1M2T
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Jul 2006 08:28:19 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx02.cybersurf.com with esmtp (Exim 4.30)
	id 1G6RS1-0007E5-99
	for netdev@vger.kernel.org; Fri, 28 Jul 2006 08:28:21 -0400
To: Lennert Buytenhek <buytenh@wantstofly.org>
In-Reply-To: <20060728111534.GD25854@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2006-28-07 at 13:15 +0200, Lennert Buytenhek wrote:
> On Fri, Jul 28, 2006 at 12:49:46PM +0200, Francois Romieu wrote:
> 
> > > The in-kernel 'r8169' drivers in 2.6.17 and 2.6.18-rc2 appear to work
> > > initially, but they don't actually seem to transmit any packets on the
> > > wire, nor do they receive any.
> > > 
> > > Boot logs from 2.6.17 and 2.6.18-rc2 attached.  Apart from the MAC
> > > address for eth1 being incorrect (boot loader bug, being worked on)
> > > there don't seem to be any strange messages or errors.
> > 
> > Can you send:
> > - the output of 'lspci -vvx' 
> 


Since you mention an incorrect MAC address: The one thing that has
bitten me in the past(twice) is misprograming of the eeprom (where
typically the MAC address would sit as well). Vendor in a hurry to put
out the NIC/board forgets to do something at manufacturing time. The
most recent was about 9 months back where the same chip was used in the
board but in one port copper was used and in another hooking up via
serdes. The eeprom claimed both to be copper. It worked for sometime
until you pulled a link and then plugged it back in. A little ethtool
magic to change the device id to match 0x107B
(E1000_DEV_ID_82546GB_SERDES) instead of 0x1079
(E1000_DEV_ID_82546GB_COPPER) fixed it.

cheers,
jamal

PS:- That box looks interesting - priced correctly i may even buy
one ;->

