From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/6] amd-xgbe: AMD 10Gb Ethernet driver updates
Date: Thu, 26 Jun 2014 17:15:13 -0700 (PDT)
Message-ID: <20140626.171513.1599540810911294287.davem@davemloft.net>
References: <20140624211900.20681.46554.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: thomas.lendacky@amd.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52443 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751102AbaF0APO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jun 2014 20:15:14 -0400
In-Reply-To: <20140624211900.20681.46554.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Lendacky <thomas.lendacky@amd.com>
Date: Tue, 24 Jun 2014 16:19:00 -0500

> The following series fixes some bugs and provides new/changed support
> in the driver.
> 
> - Make all the defines in the xgbe.h file unique by prefixing them with
>   XGBE_ if they are not currently using the prefix.
> - VLAN CTAGs are supplied in context descriptors. Tell the hardware to
>   look in the Tx context descriptor, and not a register, for the VLAN CTAG
>   to be inserted in the packet.
> - The hardware will indicate a VLAN packet has been received even if VLAN
>   CTAG stripping is currently disabled.  Only indicate that a VLAN CTAG
>   has been stripped for the current packet if stripping is enabled.
> - Add support for VLAN filtering
> - Modify destination address filtering to use the hardware hash tables
> - Eliminate a checkpatch warning by replacing sscanf with kstrtouint
> 
> This patch series is based on net-next.

Series applied, but as already mentioned I'm not happy with the debugfs
stuff, and also you didn't need to ifdef protect the definition of the
crc32 little endian polynomial define.  If someone ever puts that in
a generic place (and we should, it shows up in 3 places already) they
will take out your local define surely.
