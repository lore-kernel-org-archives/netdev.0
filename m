From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [patch net-next 0/4] net: allow to change carrier from
 userspace
Date: Fri, 14 Dec 2012 08:12:01 -0800
Message-ID: <20121214081201.1205b613@nehalam.linuxnetplumber.net>
References: <20121212184925.GD3060@minipsycho.orion>
	<20121212105448.490aca5c@nehalam.linuxnetplumber.net>
	<20121212190613.GE3060@minipsycho.orion>
	<20121212113433.21c05614@nehalam.linuxnetplumber.net>
	<20121213161750.GA1914@minipsycho.orion>
	<50CA0D3D.5000503@gmail.com>
	<20121213155423.07c47307@obelix.rh>
	<20121213100933.6d68a8e5@nehalam.linuxnetplumber.net>
	<20121213161733.7bffe897@obelix.rh>
	<20121213102051.72ad69aa@nehalam.linuxnetplumber.net>
	<20121214144134.GA1652@minipsycho.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Flavio Leitner <fbl@redhat.com>,
	John Fastabend <john.fastabend@gmail.com>,
	netdev@vger.kernel.org, davem@davemloft.net, edumazet@google.com,
	bhutchings@solarflare.com, mirqus@gmail.com,
	greearb@candelatech.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:41773 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756445Ab2LNQNR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Dec 2012 11:13:17 -0500
In-Reply-To: <20121214144134.GA1652@minipsycho.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 14 Dec 2012 15:41:34 +0100
Jiri Pirko <jiri@resnulli.us> wrote:

> Thu, Dec 13, 2012 at 07:20:51PM CET, shemminger@vyatta.com wrote:
> >On Thu, 13 Dec 2012 16:17:33 -0200
> >Flavio Leitner <fbl@redhat.com> wrote:
> >
> >> On Thu, 13 Dec 2012 10:09:33 -0800
> >> Stephen Hemminger <shemminger@vyatta.com> wrote:
> >> 
> >> > On Thu, 13 Dec 2012 15:54:23 -0200
> >> > Flavio Leitner <fbl@redhat.com> wrote:
> >> > 
> >> > > I am saying this because people are used to and there are scripts out
> >> > > there using something like:
> >> > > # ethtool <iface> | grep 'Link'
> >> > > to react an interface failure.
> >> > 
> >> > Then the script is broken. It is asking about hardware state.
> >> 
> >> I was talking about the team master interface, so it makes sense
> >> to check its 'hardware' state. Just think on 'bond0' interface
> >> with no slaves. It should report Link detected: no.
> >> 
> >> See bond_release(), what happens if bond->slave_cnt == 0, for instance.
> >> 
> >
> >I was thinking more that ethtool operation for reporting link on
> >the team device should use the proper check rather than just using netif_carrier_ok(),
> >the team ethtool operation for get_link should be check IFF_RUNNING flag
> >in dev->flags which is controlled by operstate transistions.
> 
> I admit I'm bit confused now.
> 
> For example in bridge code:
> in br_add_if() - netif_carrier_ok() is checked and by the value it is
> decided if br_stp_enable_port() is called or not. Wouldn't it make more
> sense to check IFF_RUNNING (or netif_oper_up()) here?
> 
> The reason I'm asing is that if team device is in bridge, carrier is
> always ON and I'm fiddling with IF_OPER_UP and IF_OPER_DORMANT from
> userspace, in current code, bridge wouldn't know the difference...
> 
> There are more exmaples of similar usage of netif_carrier_ok() in
> bridge (called on ports), bonding (called on slaves), team code (called on ports).

Yes the bridge should be fixed to work with user controlled devices.
