From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [evb] RE: [PATCH][RFC] net/bridge: add basic VEPA support
Date: Sat, 8 Aug 2009 11:22:28 +0200
Message-ID: <200908081122.28883.arnd@arndb.de>
References: <D2E118A1E7268F449C469EA2F301D92902BC39B2@exil.voltaire.com> <0199E0D51A61344794750DC57738F58E6D6A6CD803@GVW1118EXC.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Yaron Haviv <yaronh@voltaire.com>,
	"evb@yahoogroups.com" <evb@yahoogroups.com>,
	"shemminger@linux-foundation.org" <shemminger@linux-foundation.org>,
	"bridge@lists.linux-foundation.org"
	<bridge@lists.linux-foundation.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"virtualization@lists.linux-foundation.org"
	<virtualization@lists.linux-foundation.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"kaber@trash.net" <kaber@trash.net>,
	"adobriyan@gmail.com" <adobriyan@gmail.com>,
	"Paul Congdon (UC Davis)" <ptcongdon@ucdavis.edu>
To: "Fischer, Anna" <anna.fischer@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.8]:65341 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933768AbZHHJZu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Aug 2009 05:25:50 -0400
In-Reply-To: <0199E0D51A61344794750DC57738F58E6D6A6CD803@GVW1118EXC.americas.hpqcorp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 07 August 2009, Fischer, Anna wrote:
> If you do have a SRIOV NIC that supports VEPA, then I would think
> that you do not have QEMU or macvtap in the setup any more though.
> Simply because in that case the VM can directly access the VF on
> the physical device. That would be ideal.

There may be reasons why even with an SR-IOV adapter you may want
to use the macvtap setup, with some extensions. E.g. guest migration
becomes a lot simpler if you don't have to deal with PCI passthrough
devices. If we manage to add both TX and RX zero-copy (into the
guest) to the macvlan driver, we can treat an SR-IOV adapter like
a VMDq adapter and get the best of both.

> I do think that the macvtap driver is a good addition as a simple
> and fast virtual network I/O interface, in case you do not need
> full bridge functionality. It does seem to assume though that the
> virtualization software uses QEMU/tap interfaces. How would this
> work with a Xen para-virtualized network interface? I guess there
> would need to be yet another driver?

I'm not sure how Xen guest networking works, but if neither the
traditional macvlan driver nor the macvtap driver are able to
connect it to the external NIC, then you can probably add a third
macvlan backend to handle that.

	Arnd <><
