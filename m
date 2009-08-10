From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [Bridge] [PATCH] macvlan: add tap device backend
Date: Mon, 10 Aug 2009 21:04:54 +0200
Message-ID: <200908102104.54527.arnd@arndb.de>
References: <0199E0D51A61344794750DC57738F58E6D6A6CD7F6@GVW1118EXC.americas.hpqcorp.net> <200908080005.32443.arnd@arndb.de> <0199E0D51A61344794750DC57738F58E6D6AE99700@GVW1118EXC.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: "Paul Congdon (UC Davis)" <ptcongdon@ucdavis.edu>,
	"drobbins@funtoo.org" <drobbins@funtoo.org>,
	"herbert@gondor.apana.org.au" <herbert@gondor.apana.org.au>,
	"mst@redhat.com" <mst@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"bridge@lists.linux-foundation.org"
	<bridge@lists.linux-foundation.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"ogerlitz@voltaire.com" <ogerlitz@voltaire.com>,
	"evb@yahoogroups.com" <evb@yahoogroups.com>,
	"davem@davemloft.net" <davem@davemloft.net>
To: "Fischer, Anna" <anna.fischer@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.8]:62984 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751093AbZHJTG4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Aug 2009 15:06:56 -0400
In-Reply-To: <0199E0D51A61344794750DC57738F58E6D6AE99700@GVW1118EXC.americas.hpqcorp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 10 August 2009, Fischer, Anna wrote:
> If you compare macvtap with traditional QEMU networking interfaces that
> are typically used in current bridged setups, then yes, performance will be
> different. However, I think that this is not necessarily a fair 
> comparison, and the performance difference does not come from the 
> bridge being slow, but simply because you have implemented a better
> solution to connect a virtual interface to a backend device that
> can be assigned to a VM. There is no reason why you could not do this
> for a bridge port as well.

It's not necessarily the bridge itself being slow (though some people
claim it is) but more the bridge preventing optimizations or making
them hard.

You already mentioned hardware filtering by unicast and multicast
mac addresses, which macvlan already does (for unicast) but which would be
relatively complex with a bridge due to the way it does MAC address
learning.

If we want to do zero copy receives, the hardware will on top of
this have to choose the receive buffer based on the mac address,
with the buffer provided by the guest. I think this is not easy
with macvlan but doable, while I have no idea where you would start
using the bridge code.

	Arnd <><
