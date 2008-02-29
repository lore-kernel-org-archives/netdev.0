From: David Miller <davem@davemloft.net>
Subject: Re: Purpose of __net_exit & friends
Date: Fri, 29 Feb 2008 12:23:55 -0800 (PST)
Message-ID: <20080229.122355.90044797.davem@davemloft.net>
References: <1204292458-11636-12-git-send-email-den@openvz.org>
	<20080229.112342.76764059.davem@davemloft.net>
	<20080229201247.GA7139@uranus.ravnborg.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: den@openvz.org, netdev@vger.kernel.org, containers@lists.osdl.org
To: sam@ravnborg.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38721
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752252AbYB2UX4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Feb 2008 15:23:56 -0500
In-Reply-To: <20080229201247.GA7139@uranus.ravnborg.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sam Ravnborg <sam@ravnborg.org>
Date: Fri, 29 Feb 2008 21:12:47 +0100

> On Fri, Feb 29, 2008 at 11:23:42AM -0800, David Miller wrote:
> > From: "Denis V. Lunev" <den@openvz.org>
> > Date: Fri, 29 Feb 2008 16:40:58 +0300
> > 
> > > +static void __net_exit icmpv6_sk_exit(struct net *net)
> > > +{
> > 
> > Since you call this from __new_init code, won't this
> > create a section conflict when ipv6 is built statically
> > into the kernel?
> 
> I have noticed this __net_init/__net_exit stuff before
> but never got around to ask about it.
> 
> Whats the actual purpose and are there any strict
> rules as to what may be called from where?
> If there are we should apply the same checks as we do
> for __devinit/__devexit and friends.

Basically, if network namespace support isn't enabled,
these functions can act like normal __init and __exit
functions.

Otherwise we have to keep them around so that they can
be called when namespaces are created and destroyed.
