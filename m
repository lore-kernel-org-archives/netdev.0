From: David Miller <davem@davemloft.net>
Subject: flow director and packet ordering
Date: Mon, 15 Jun 2009 02:07:38 -0700 (PDT)
Message-ID: <20090615.020738.243788769.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34674
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751521AbZFOJHf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jun 2009 05:07:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Does the flow director implementation in IXGBE make sure to preserve
packet ordering in some way?

You can't just change the RX flow destination queue whenever you like.

For example, if a transmit happens on cpu 1, then we start to receive
some packets for that flow on that cpu, will a sudden set of transmits
on another cpu make the flow director quickly switch the RX
destination?

That would be very bad.

Without some extreme care that will result in potential packet
reordering.

There needs to be some safey net in place in your silicon to wait for
a significant "quiet time" in the RX stream before you can revector
the RX flow destination setting.  Enough time to let the stack process
all that packets for that flow received on the currently bound flow
CPU.

To be honest, I'm not optimistic about this situation :-/
