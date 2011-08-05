From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 NEXT 1/1] netxen: add vlan accel support
Date: Fri, 05 Aug 2011 04:27:55 -0700 (PDT)
Message-ID: <20110805.042755.2121843538632981106.davem@davemloft.net>
References: <99737F4847ED0A48AECC9F4A1974A4B80FE464EF82@MNEXMB2.qlogic.org>
	<20110805.032606.1214964517719657458.davem@davemloft.net>
	<99737F4847ED0A48AECC9F4A1974A4B80FE464EF99@MNEXMB2.qlogic.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	rajesh.borundia@qlogic.com
To: amit.salecha@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:45209 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753374Ab1HEL16 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Aug 2011 07:27:58 -0400
In-Reply-To: <99737F4847ED0A48AECC9F4A1974A4B80FE464EF99@MNEXMB2.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amit Salecha <amit.salecha@qlogic.com>
Date: Fri, 5 Aug 2011 06:04:10 -0500

> This is true, but problem is after fw recovery. So flow is 
> 1) vlan device added
> 2) Driver program ip address of vlan device (through inet events)
> 3) Fw recovery
> 4) After fw recovery driver need to program ip addresses again which were already programmed.
>    After fw recovery there won't be any inet/netdev event.
> 
> Simple solution is to maintain those ip addresses in driver.

When you program the device, in response to inet events, maintain a
software list in the driver that remembers the IP address state.

Then on FW recovery, walk the special list to reprogram the device.
