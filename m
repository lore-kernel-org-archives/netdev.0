From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] dmfe/tulip: Let dmfe handle DM910x except for SPARC
 on-board chips
Date: Sun, 03 Jan 2010 21:36:28 -0800 (PST)
Message-ID: <20100103.213628.48383743.davem@davemloft.net>
References: <20091130.142925.23220838.davem@davemloft.net>
	<20091229182228.GE20379@decadent.org.uk>
	<20091229184151.GA20122@lackof.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ben@decadent.org.uk, brandon@ifup.org, grundler@google.com,
	tobias@ringis.se, kyle@mcmartin.ca, netdev@vger.kernel.org
To: grundler@parisc-linux.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43149
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753026Ab0ADFg0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2010 00:36:26 -0500
In-Reply-To: <20091229184151.GA20122@lackof.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Grant Grundler <grundler@parisc-linux.org>
Date: Tue, 29 Dec 2009 11:41:52 -0700

> On Tue, Dec 29, 2009 at 06:22:28PM +0000, Ben Hutchings wrote:
>> The Davicom DM9100 and DM9102 chips are used on the motherboards of
>> some SPARC systems (supported by the tulip driver) and also in PCI
>> expansion cards (supported by the dmfe driver).  There is no
>> difference in the PCI device ids for the two different configurations,
>> so these drivers both claim the device ids.  However, it is possible
>> to distinguish the two configurations by the presence of Open Firmware
>> properties for them, so we do that.
>> 
>> Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
> 
> Acked-by: Grant Grundler <grundler@parisc-linux.org>
> 
> I've reviewed the code and it looks fine to me.
> 
> Only thing I'm not sure about is if "KERN_ERR" is
> the right priority for what are essentially warning
> messages. Not harmful. But could be annoying to some
> Sparc users who get this on every boot when both modules
> are present and loaded in the "wrong" order.

I agree, KERN_INFO is more appropriate here.

Also, for the of_get_property() calls, you don't need to pass
in a dummy "&len", just pass NULL.  This will avoid the dummy
local variable 'len'.

Make these two fixups and I'll apply this to net-2.6

Thanks!
