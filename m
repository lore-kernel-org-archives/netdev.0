From: "Williams, Mitch A" <mitch.a.williams@intel.com>
Subject: RE: [PATCH 1/2] igb: Implement reading of reg RQDPC (Receive Queue
	Drop Packet Count)
Date: Wed, 13 May 2009 15:07:56 -0600
Message-ID: <EA929A9653AAE14F841771FB1DE5A1365F7A1DF466@rrsmsx501.amr.corp.intel.com>
References: <1241703346.18487.22.camel@localhost.localdomain>
	 <1241703431.18487.25.camel@localhost.localdomain>
	 <EA929A9653AAE14F841771FB1DE5A1365F7744D662@rrsmsx501.amr.corp.intel.com>
 <1242035422.18487.78.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
To: Jesper Dangaard Brouer <hawk@comx.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:20068 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753234AbZEMVH5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2009 17:07:57 -0400
In-Reply-To: <1242035422.18487.78.camel@localhost.localdomain>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 

>-----Original Message-----
>From: Jesper Dangaard Brouer [mailto:hawk@comx.dk] 
>Sent: Monday, May 11, 2009 2:50 AM
>
>I have now tested it on a 82575 chip NIC. (I just got my 82575 NIC
>working again (This 12 port monster from Hotlava Systems, just needed
>more power on PCIe 100Watt)).
>
>I don't see the reason for doing special checks for the 82575. Reading
>the RQDPC registers on 82575 always returns 0.  I don't see any harm in
>that!?  (it also returns zero in overload situations)
>
>What do you want to redraw your NAK?
>

Jesper, I still stand by my NAK.  It's never ever a good idea to read
non-existent hardware registers.  You don't know what effect those
reads will have on the hardware.  These addresses may be aliased to other
registers without being documented.  Hardware designers do this all the
time to save a few gates in the address decode logic, and these aliases
may or may not be documented.  If this is the case, reading these
registers will have unintended consequences.  You might be clearing some
other statistic, or worse.

Since we just don't know, it's better to be safe than sorry.  Wrap
those register reads so they only happen on 82576, and I'll happily
ack your patch.

-Mitch