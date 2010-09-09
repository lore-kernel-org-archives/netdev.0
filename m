From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [RFC PATCH 0/4] Implement multiqueue virtio-net
Date: Thu, 9 Sep 2010 12:40:27 +0200
Message-ID: <201009091240.27969.arnd@arndb.de>
References: <20100908072859.23769.97363.sendpatchset@krkumar2.in.ibm.com> <201009081612.41976.arnd@arndb.de> <OF025FB4DD.0A1D8CAD-ON65257798.00527BE1-65257798.005C0247@in.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: anthony@codemonkey.ws, Avi Kivity <avi@redhat.com>,
	davem@davemloft.net, kvm@vger.kernel.org, mst@redhat.com,
	netdev@vger.kernel.org, rusty@rustcorp.com.au
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.9]:51881 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752443Ab0IIKkz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Sep 2010 06:40:55 -0400
In-Reply-To: <OF025FB4DD.0A1D8CAD-ON65257798.00527BE1-65257798.005C0247@in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 08 September 2010, Krishna Kumar2 wrote:
> > On Wednesday 08 September 2010, Krishna Kumar2 wrote:
> > > > The new guest and qemu code work with old vhost-net, just with
> reduced
> > > > performance, yes?
> > >
> > > Yes, I have tested new guest/qemu with old vhost but using
> > > #numtxqs=1 (or not passing any arguments at all to qemu to
> > > enable MQ). Giving numtxqs > 1 fails with ENOBUFS in vhost,
> > > since vhost_net_set_backend in the unmodified vhost checks
> > > for boundary overflow.
> > >
> > > I have also tested running an unmodified guest with new
> > > vhost/qemu, but qemu should not specify numtxqs>1.
> >
> > Can you live migrate a new guest from new-qemu/new-kernel
> > to old-qemu/old-kernel, new-qemu/old-kernel and old-qemu/new-kernel?
> > If not, do we need to support all those cases?
> 
> I have not tried this, though I added some minimal code in
> virtio_net_load and virtio_net_save. I don't know what needs
> to be done exactly at this time. I forgot to put this in the
> "Next steps" list of things to do.

I was mostly trying to find out if you think it should work
or if there are specific reasons why it would not.
E.g. when migrating to a machine that has an old qemu, the guest
gets reduced to a single queue, but it's not clear to me how
it can learn about this, or if it can get hidden by the outbound
qemu.

	Arnd
