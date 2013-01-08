From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [Xen-devel] xen-netback notify DomU to send ARP.
Date: Tue, 8 Jan 2013 16:00:34 +0000
Message-ID: <1357660834.12649.103.camel@dagon.hellion.org.uk>
References: <50EC099D.6020407@oracle.com>
	 <50EC297A02000078000B3BB5@nat28.tlf.novell.com>
	 <1357652541.7989.179.camel@zakaz.uk.xensource.com>
	 <50EC3DFD.8060206@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
To: jianhai luan <jianhai.luan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([46.33.159.39]:29505 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756329Ab3AHQAg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2013 11:00:36 -0500
In-Reply-To: <50EC3DFD.8060206@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-01-08 at 15:40 +0000, jianhai luan wrote:
> 
> On 2013-1-8 21:42, Ian Campbell wrote: 
> > On Tue, 2013-01-08 at 13:13 +0000, Jan Beulich wrote: 
> > > > > > On 08.01.13 at 12:57, jianhai luan <jianhai.luan@oracle.com>
> > > > > > wrote: 
> > > >     When Xen Dom0's network circumstance changed, DomU 
> > > > should be notified in some special condition. For 
> > > > example the below circumstance: 
> > > >     ping from Guest A to DomU: 
> > > >     Guest A --> eth0 - bond0 - xenbr0 --VIF(DOMU) 
> > > >                 eth1 / 
> > > >     when eth0 inactive, and eth1 active. 
> > How is eth0 failing? Are you unplugging it, un-enslaving it or
> > taking 
> > some other sort of administrative action? 
> In my emulation environment, i unplug it or ifdown the interface,

I expect these would behave rather different, since the affect of ifdown
looks rather different to an unplug from the PoV of the switch.

Is the ifdown case something which you are trying to solve or just what
appeared to be a convenient test case? I'd be less inclined to worry
about explict admin actions such as that.

Unplugging the cable should cause:

> > Doesn't this state change cause the switch to which eth0 and eth1
> > are 
> > attached to forget the MAC tables associated with the eth0 port,
> > meaning 
> > that subsequent traffic will be flooded until it learns that eth1 is
> > the 
> > new port? 

Ian
