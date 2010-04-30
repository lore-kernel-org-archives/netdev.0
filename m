From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: ixgbe and mac-vlans problem
Date: Fri, 30 Apr 2010 20:00:58 +0200
Message-ID: <201004302000.58763.arnd@arndb.de>
References: <4BDA07DB.8020206@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>, Patrick McHardy <kaber@trash.net>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.171]:64068 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758985Ab0D3SBH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Apr 2010 14:01:07 -0400
In-Reply-To: <4BDA07DB.8020206@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 30 April 2010 00:27:39 Ben Greear wrote:
> Basically, we create 50 mac-vlans, with sequential MAC addresses and sequential
> IP addresses, and set up ip rules properly.
> 
> The issue is that only 10 or so of the mac-vlans receive other than
> broadcast packets.  The ixgbe NIC doesn't show PROMISC mode.

I just took a brief look at the driver and noticed that 82599 should
be able to handle 128 entries before going into promisc mode, while
82598 (the same driver) does 16.

Maybe the logic for >16 entries is wrong, so you could try forcing
hw->mac.num_rar_entries to 16 for 82599 as well.

	Arnd
