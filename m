From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: Lots of "BUG eth1 code -5 qlen 0" messages in 2.6.24
Date: Fri, 1 Feb 2008 11:07:18 -0800
Message-ID: <D5C1322C3E673F459512FB59E0DDC32904737D7B@orsmsx414.amr.corp.intel.com>
References: <20080129184726.GA29300@gateway.home> <D5C1322C3E673F459512FB59E0DDC329046C6CC7@orsmsx414.amr.corp.intel.com> <1201640243.4431.29.camel@localhost> <20080129214555.GC29300@gateway.home> <1201648108.4425.15.camel@localhost> <20080201145446.GA3661@gateway.home>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: "Erik Mouw" <mouw@nl.linux.org>, "jamal" <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:47298 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753949AbYBATIe convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Feb 2008 14:08:34 -0500
Content-class: urn:content-classes:message
In-Reply-To: <20080201145446.GA3661@gateway.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I've changed the -EIO into NETDEV_TX_BUSY and so far I can't 
> trigger the bug anymore. It was quite easy to trigger within 
> minutes with rsync, but I can't trigger it anymore. Should I 
> send a patch, and if
> so: to who? The tulip/xircom_cb driver seems to be orphaned.

Perhaps Jeff Garzik is a good place to start.  He maintains the driver
tree, he either can take the patch or direct you to where it should go.

> No need to test that, it *is* netif_stopped before the return:
> 
>         /* Uh oh... no free descriptor... drop the packet */
>         netif_stop_queue(dev);
>         spin_unlock_irqrestore(&card->lock,flags);
>         trigger_transmit(card);
> 
>         return NETDEV_TX_BUSY;
> 
> trigger_transmit() is a simple function that just writes a 
> single register on the card to trigger a transmit.

Eek!  No need to make this smarter at this point, but this is pretty
basic.

Cheers,

-PJ Waskiewicz
