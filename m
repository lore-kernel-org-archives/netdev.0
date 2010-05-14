From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [net-next-2.6 V7 PATCH 1/2] Add netlink support for virtual port management (was iovnl)
Date: Fri, 14 May 2010 19:29:40 +0200
Message-ID: <201005141929.41534.arnd@arndb.de>
References: <C812D414.3180C%scofeldm@cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, davem@davemloft.net,
	netdev@vger.kernel.org, chrisw@redhat.com
To: Scott Feldman <scofeldm@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.8]:53483 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757348Ab0ENRaG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 May 2010 13:30:06 -0400
In-Reply-To: <C812D414.3180C%scofeldm@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 14 May 2010 19:19:00 Scott Feldman wrote:
> I want to make sure I've got this right before starting on ver8 of patch:
> 
>     - we'll use the layout listed above
> 
>     - RTM_SETLINK msg includes the full nested layout
> 
>         - contains IFLA_VF_PORTs for all VFs of a PF
>         - OR, contains IFLA_PORT_SELF if PF is it's own VF
> 
>         - it's up to the receiver to compare for changes for each VF
> 
>     - RTM_GETLINK msg includes the full nested layout
> 
>         - same rules as RTM_SETLINK above

I was thinking that a device could have both IFLA_VF_PORTS and IFLA_PORT_SELF,
but you know more about the IOV specifics. If an adapter having multiple
VFs always gets configured as VF 0 itself, that would be fine as well, otherwise
we could have an extra argument to the two device driver callbacks to
differentiate VF/SELF. As long as this does not impact the user ABI, we
could do either.
 
> I think we should redo the other IFLA_VF_xxx msgs in the same style.  I'm
> not going to tackle that for IFLA_VF_PORTS patch, but it would be a good
> followup patch.

I fear it's too late for that now. While we have not yet released 2.6.34
and 2.6.33 does not contain the broken message, it's extremely late in the
stabilization phase of v2.6.34, so I doubt that there is still a chance for
that at this point.

	Arnd
