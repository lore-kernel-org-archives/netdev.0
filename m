From: Nolan Leake <nolan@cumulusnetworks.com>
Subject: Re: tap0 device stopped working in 2.6.36 (ok in 2.6.35)
Date: Wed, 27 Oct 2010 10:48:54 -0700
Message-ID: <1288201734.26640.43.camel@voxel>
References: <4CC2DB2C.3060908@xs4all.nl> <1287862760.7499.225.camel@voxel>
	 <4CC40398.6070105@xs4all.nl> <1288142302.26640.7.camel@voxel>
	 <4CC84EAD.7040506@xs4all.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Jim <jim876@xs4all.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from phong.sigbus.net ([65.49.35.42]:52652 "EHLO phong.sigbus.net"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753334Ab0J0Rs4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Oct 2010 13:48:56 -0400
In-Reply-To: <4CC84EAD.7040506@xs4all.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-10-27 at 18:09 +0200, Jim wrote:
> Not exactly, VirtualBox calls it "bridged adapter", it 'bridges' the
> guest machine to the tap0 interface on the host for so called host-only
> networking.
> See eg. http://forums.virtualbox.org/viewtopic.php?f=1&t=165

OK, so you have the tap0 device, and you assign an IP to it and run
dhcpd on it.  Understood.  Thank you for the explanatory link.

> And this sequence is now simply failing
>   tunctl -t tap0 -u tuxuser
>   ifconfig tap0 10.0.0.1 up

The link is not ready until some process has attached to the tap device.
tunctl simply attaches and then immediately detaches, leaving it
link-down until the virtualbox process starts and attaches.

But this doesn't cause the problem for me!  I suspect that is because I
am running an ipv4 only kernel; the "ADDRCONF(NETDEV_UP): tap0: link is
not ready" error comes from net/ipv6/addrconf.c.

I have no idea why ipv6 vetos the upping of a link-down interface, while
ipv4 doesn't care.

If this is all intended behavior, then I guess I'll need to make the old
"tap devices are always link-up" mode the default, and add a way for
newer software to opt-in into correct link-state reporting.

David (CC'd), could you comment on this?

Thanks,
Nolan
