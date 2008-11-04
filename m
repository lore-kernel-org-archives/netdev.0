From: David Miller <davem@davemloft.net>
Subject: Re: zeroing dev->irq
Date: Mon, 03 Nov 2008 19:28:20 -0800 (PST)
Message-ID: <20081103.192820.125970076.davem@davemloft.net>
References: <490B2DA4.30903@garzik.org>
	<20081031163851.GA16253@gospo.rdu.redhat.com>
	<490B36B6.2020300@garzik.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andy@greyhouse.net, mcarlson@broadcom.com, netdev@vger.kernel.org,
	mchan@broadcom.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47907
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752536AbYKDD2p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Nov 2008 22:28:45 -0500
In-Reply-To: <490B36B6.2020300@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Garzik <jeff@garzik.org>
Date: Fri, 31 Oct 2008 12:47:50 -0400

> Andy Gospodarek wrote:
> > This came up because the output is currently wrong.
> > # ifconfig eth0 | grep Inter && grep eth0 /proc/interrupts
> >           Interrupt:169 Memory:f6000000-f6012100
> > 122:       2894           0          0         PCI-MSI  eth0
> > Some drivers take the stand of not setting dev->irq anything (like most
> > of the Intel drivers), but I didn't take that route with tg3 (or with
> > the others I'd planned) simply because I didn't want to hear crying
> > about breaking user-space with a patch that would make that line
> > disappear.
> > If this seems like a reasonable change that we can force on user-space
> > I'll post a patch that drops the setting of dev->irq all together, so
> > this disappers.
>
> I would vote for zeroing dev->irq in not only tg3, but also other
> modern, ethtool-enabled drivers...  It is a relic of the ISA days,
> and is incompatible with multiple MSI vector scenarios, something
> also found on some non-x86 and embedded ethernet drivers.
>
> For years now, dev->irq has been providing information on an
> unreliable, best-effort basis.  I prefer definitive, reliable,
> predictable behaviors, and think always-zero is therefore an
> improvement.
>
> Comments welcome...

I completely agree with Jeff and I'll happily take patches
which do this into net-next-2.6
