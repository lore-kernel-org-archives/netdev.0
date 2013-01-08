From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [Xen-devel] xen-netback notify DomU to send ARP.
Date: Tue, 8 Jan 2013 13:42:21 +0000
Message-ID: <1357652541.7989.179.camel@zakaz.uk.xensource.com>
References: <50EC099D.6020407@oracle.com>
	 <50EC297A02000078000B3BB5@nat28.tlf.novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: jianhai luan <jianhai.luan@oracle.com>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jan Beulich <JBeulich@suse.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([46.33.159.39]:4790 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756381Ab3AHNmX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2013 08:42:23 -0500
In-Reply-To: <50EC297A02000078000B3BB5@nat28.tlf.novell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-01-08 at 13:13 +0000, Jan Beulich wrote:
> >>> On 08.01.13 at 12:57, jianhai luan <jianhai.luan@oracle.com> wrote:
> >    When Xen Dom0's network circumstance changed, DomU
> > should be notified in some special condition. For
> > example the below circumstance:
> >    ping from Guest A to DomU:
> >    Guest A --> eth0 - bond0 - xenbr0 --VIF(DOMU)
> >                eth1 /
> >    when eth0 inactive, and eth1 active.

How is eth0 failing? Are you unplugging it, un-enslaving it or taking
some other sort of administrative action?

Which bonding mode are you using?

Doesn't this state change cause the switch to which eth0 and eth1 are
attached to forget the MAC tables associated with the eth0 port, meaning
that subsequent traffic will be flooded until it learns that eth1 is the
new port?

> >    Guest A --> eth0   bond0 - xenbr0 --VIF(DOMU)
> >                eth1 /
> >    Guest A will don't reach to DomU. After Guest A
> >    send ARP request and DomU respond, Guest A will
> >    reach DomU. But some more second will be elapsed.
> >                eth0   bond0 - xenbr0 --VIF(DOMU)
> >    Guest A --> eth1/
> 
> Isn't a change to the availability of the bonds supposed to be
> transparent to Guest A _and_ DomU? I.e. aren't you trying to fix
> an eventual problem here in the wrong place?

In non-virtualised bonding the bonding drive can take care of some of
this because it knows its own MAC address and can send appropriate
gratuitous frames (depends on the bonding mode) to paper over things. In
the virtualised case it (most likely) doesn't know VIF(DOMU)s MAC
address.

> > If Xen netback watch the network change, will notify
> > DomU by change it own status. So netfront will watch
> > netback's change, and DomU send ARP initiative.
> 
> Your patch is, at least according to what I see, completely
> unusable - line breaks dropped, line order reversed, and
> (guessing) some UTF-16/UCS-2 characters inserted at the top.
> Please attach patches as plain ASCII.

>From the name it looks to me like it is the vi temp file created while
you have the file open rather than the actual patch file...

Ian.
