From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [patch net-next 0/4] net: allow to change carrier from
 userspace
Date: Thu, 13 Dec 2012 10:20:51 -0800
Message-ID: <20121213102051.72ad69aa@nehalam.linuxnetplumber.net>
References: <20121212170520.GA3060@minipsycho.orion>
	<20121212092700.7ef2607a@nehalam.linuxnetplumber.net>
	<20121212181017.GB3060@minipsycho.orion>
	<20121212101208.361ccda0@nehalam.linuxnetplumber.net>
	<20121212182556.GC3060@minipsycho.orion>
	<20121212103632.2020efce@nehalam.linuxnetplumber.net>
	<20121212184925.GD3060@minipsycho.orion>
	<20121212105448.490aca5c@nehalam.linuxnetplumber.net>
	<20121212190613.GE3060@minipsycho.orion>
	<20121212113433.21c05614@nehalam.linuxnetplumber.net>
	<20121213161750.GA1914@minipsycho.orion>
	<50CA0D3D.5000503@gmail.com>
	<20121213155423.07c47307@obelix.rh>
	<20121213100933.6d68a8e5@nehalam.linuxnetplumber.net>
	<20121213161733.7bffe897@obelix.rh>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.fastabend@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org,
	davem@davemloft.net, edumazet@google.com,
	bhutchings@solarflare.com, mirqus@gmail.com,
	greearb@candelatech.com
To: Flavio Leitner <fbl@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:56433 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753481Ab2LMSWG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Dec 2012 13:22:06 -0500
In-Reply-To: <20121213161733.7bffe897@obelix.rh>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 13 Dec 2012 16:17:33 -0200
Flavio Leitner <fbl@redhat.com> wrote:

> On Thu, 13 Dec 2012 10:09:33 -0800
> Stephen Hemminger <shemminger@vyatta.com> wrote:
> 
> > On Thu, 13 Dec 2012 15:54:23 -0200
> > Flavio Leitner <fbl@redhat.com> wrote:
> > 
> > > I am saying this because people are used to and there are scripts out
> > > there using something like:
> > > # ethtool <iface> | grep 'Link'
> > > to react an interface failure.
> > 
> > Then the script is broken. It is asking about hardware state.
> 
> I was talking about the team master interface, so it makes sense
> to check its 'hardware' state. Just think on 'bond0' interface
> with no slaves. It should report Link detected: no.
> 
> See bond_release(), what happens if bond->slave_cnt == 0, for instance.
> 

I was thinking more that ethtool operation for reporting link on
the team device should use the proper check rather than just using netif_carrier_ok(),
the team ethtool operation for get_link should be check IFF_RUNNING flag
in dev->flags which is controlled by operstate transistions.
