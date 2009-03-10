From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: Marvell 88E609x switch?
Date: Tue, 10 Mar 2009 10:56:28 +0100
Message-ID: <20090310095628.GM4738@xi.wantstofly.org>
References: <20090227153102.GH17040@xi.wantstofly.org> <49A80A75.8000101@mlbassoc.com> <20090227155224.GK17040@xi.wantstofly.org> <Pine.LNX.4.64.0902272211260.19905@ask.diku.dk> <20090227222802.GZ17040@xi.wantstofly.org> <1235991382.30736.62.camel@localhost.localdomain> <1235991937.30736.65.camel@localhost.localdomain> <49ABF7DF.8060302@mlbassoc.com> <49ABF9A9.2040608@mlbassoc.com> <Pine.LNX.4.64.0903022237580.1863@ask.diku.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Gary Thomas <gary@mlbassoc.com>, jdb@comx.dk,
	netdev <netdev@vger.kernel.org>
To: Jesper Dangaard Brouer <hawk@diku.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([80.101.37.227]:37079 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753383AbZCJJ4b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2009 05:56:31 -0400
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0903022237580.1863@ask.diku.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 02, 2009 at 11:05:29PM +0100, Jesper Dangaard Brouer wrote:

> >>My understanding is that this should work via the VLAN map?
> 
> I think that the "VLAN map/table" has gotten a wrong name as it does not 
> really determine the VLANs, it only says who can talk to whom.  The switch 
> does support a real vlan setup, but its deactivated in Lennerts driver, as 
> I guess he wants Linux to handle the VLANs.  (I use the real VLAN setup 
> extensively in my driver).

I have some patches that make use of this (see the earlier h/w
bridging patch I posted to netdev@ -- I've extended that to handle
VLANs as well).  Without those patches, each port will just have its
own address database.


> >>I checked that setup and it looks OK.
> 
> I have also checked the different registers setting, and things looks 
> quite alright.  Although I'm missing the register datasheets for the 6131 
> chip, I found that I only have part 1 of 3 crap...
> 
> I did find that the 6095 and 6097 does differ in the way DSA handling is 
> done, as the 6097 supports Ethertype DSA and 6095 don't.  But the 6131 
> driver looks like it does the right thing for the 6095.

For the gigabit switches, there are more or less two groups of
switches from a register programming point of view.

Group 1:
- models: 6045, 6045f, 6092, 6095, 6095f, 6121, 6122,
  6131, 6152, 6155, 6182, 6185
- Support Header and DSA tagging.
- MAC address programmed directly via global 1/2/3.
- PPU handling generally needed.

Group 2:
- models: 6046, 6046f, 6085, 6096 (FE), 6097, 6097f, 6123, 6161, 6165 
- Support Header, DSA and Ethertype DSA tagging.
- MAC address programmed indirectly via global 1/2.
- PPU handling generally not needed.
- Extended stats access via bits [8:5]

(And of course, various advanced queueing/filtering capabilities are
only available in the higher end switches, but we don't use those
capabilities for now.)

So the 6095 is in the first group and the 6097 in the second.

The 6131 driver can probably be very easily extended to handle all
switches in the first group, and the 6123/6161/6165 driver can probably
be easily extended to handle all switches in the second group.
