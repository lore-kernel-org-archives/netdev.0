From: Christer Ekholm <che@chrekh.se>
Subject: Re: [Bug 43277] New: net/e1000e set mtu larger than 1500 fails
Date: Tue, 22 May 2012 20:39:49 +0200
Message-ID: <20411.56693.728125.121309@ender.chrekh.se>
References: <20120522111950.4548747c@nehalam.linuxnetplumber.net>
	<20120522112518.70294c0e@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"Allan\, Bruce W" <bruce.w.allan@intel.com>,
	e1000-devel@lists.sf.net
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay-b12.telenor.se ([62.127.194.21]:33650 "EHLO
	smtprelay-b12.telenor.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752607Ab2EVSjx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 May 2012 14:39:53 -0400
Received: from ipb3.telenor.se (ipb3.telenor.se [195.54.127.166])
	by smtprelay-b12.telenor.se (Postfix) with ESMTP id D48E7C1AE
	for <netdev@vger.kernel.org>; Tue, 22 May 2012 20:39:50 +0200 (CEST)
In-Reply-To: <20120522112518.70294c0e@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger writes:
 > On Tue, 22 May 2012 11:19:50 -0700
 > Stephen Hemminger <shemminger@vyatta.com> wrote:
 > 
 > 
 > I believe the problem is detected here. Check system console log (dmesg).
 > The hardware does not allow receive hashing and checksum offload together
 > in Jumbo mode.
 > 
 > 	/*
 > 	 * IP payload checksum (enabled with jumbos/packet-split when
 > 	 * Rx checksum is enabled) and generation of RSS hash is
 > 	 * mutually exclusive in the hardware.
 > 	 */
 > 	if ((netdev->features & NETIF_F_RXCSUM) &&
 > 	    (netdev->features & NETIF_F_RXHASH)) {
 > 		e_err("Jumbo frames cannot be enabled when both receive checksum offload and receive hashing are enabled.  Disable one of the receive offload features before enabling jumbos.\n");
 > 		return -EINVAL;
 > 	}

Yes you are right.

 e1000e 0000:05:00.1: eth1: Jumbo frames cannot be enabled when both receive checksum offload and receive hashing are enabled.  Disable one of the receive offload features before enabling jumbos.

How stupid of me to not see that. 

After turning rxhash of, setting of mtu to 9000 is possible again.

$ sudo ethtool -K eth1 rxhash off

$ sudo ip link set eth1 mtu 9000


Sorry to have wasted your time.

 
-- 
 Christer
