From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [evb] RE: [PATCH][RFC] net/bridge: add basic VEPA support
Date: Mon, 10 Aug 2009 17:28:15 +0200
Message-ID: <200908101728.15649.arnd@arndb.de>
References: <D2E118A1E7268F449C469EA2F301D92902BC39B2@exil.voltaire.com> <4A7EB0AC.2030104@Voltaire.com> <20090810082037.17b352c2@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Or Gerlitz <ogerlitz@voltaire.com>,
	"Paul Congdon (UC Davis)" <ptcongdon@ucdavis.edu>,
	anna.fischer@hp.com, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org, davem@davemloft.net,
	adobriyan@gmail.com, virtualization@lists.linux-foundation.org,
	"evb@yahoogroups.com" <evb@yahoogroups.com>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.10]:58136 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753043AbZHJP2T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Aug 2009 11:28:19 -0400
In-Reply-To: <20090810082037.17b352c2@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 10 August 2009, Stephen Hemminger wrote:
> On Sun, 09 Aug 2009 14:19:08 +0300, Or Gerlitz <ogerlitz@voltaire.com> wrote:
> > Looking in macvlan_set_multicast_list() it acts in a similar manner to
> > macvlan_set_mac_address() in the sense that it calls dev_mc_sync(). I
> > assume what's left is to add macvlan_hash_xxx multicast logic to
> > map/unmap multicast groups to what macvlan devices want to receive them
> > and this way the flooding can be removed, correct?
> 
> The device can just flood all multicast packets, since the filtering
> is done on the receive path anyway.

But we'd still have to copy the frames to user space (for both
macvtap and raw packet sockets) and exit from the guest to inject
it into its stack, right?

I guess for multicast heavy workloads, we could save a lot of cycles
by throwing the frames away as early as possible. How common are those
setups in virtual servers though?

	Arnd <><
