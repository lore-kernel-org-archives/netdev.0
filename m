From: Ricardo =?utf-8?b?VHViw61v?= <rtpardavila@gmail.com>
Subject: Re: Single socket with =?utf-8?b?VFhfUklORw==?= and =?utf-8?b?UlhfUklORw==?=
Date: Wed, 15 May 2013 14:58:06 +0000 (UTC)
Message-ID: <loom.20130515T165501-421@post.gmane.org>
References: <loom.20130515T144941-798@post.gmane.org> <51938BAD.5050502@redhat.com> <loom.20130515T152203-727@post.gmane.org> <5193A00E.2020507@redhat.com> <5193A128.8030204@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:47297 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759300Ab3EOO6Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 May 2013 10:58:24 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1Ucd9q-0006vq-O4
	for netdev@vger.kernel.org; Wed, 15 May 2013 16:58:22 +0200
Received: from static-adsl-c-5-188.ipcom.comunitel.net ([static-adsl-c-5-188.ipcom.comunitel.net])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 15 May 2013 16:58:22 +0200
Received: from rtpardavila by static-adsl-c-5-188.ipcom.comunitel.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 15 May 2013 16:58:22 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Daniel Borkmann <dborkman <at> redhat.com> writes:

> 
> No, just as a side note, I think here you rather wanted to say ...
> 
>   setsockopt(socket, SOL_PACKET, PACKET_RX_RING, ...);
>   setsockopt(socket, SOL_PACKET, PACKET_TX_RING, ...);
> 
> ... and then only once:
> 
>   ring = mmap(NULL, ..., socket, 0);
> 
> > I haven't tried it out yet, and currently also do not really have time
to. But
> > looking at the mmap code, it seems that the size of the mmap area is
accumulated
> > for rx and tx ring. However, the header status bits are not really
interoperable
> > with each other. So looks you will need to have two sockets ...
> 

I have already tried that and, if I use the same socket_fd twice with
setsockopt(), I get the EBUSY errno from Kernel. Tomorrow, I will try the
first solution with both sockets (it seems the easiest way); afterwards, I
will try to use the TX_RING socket for TX and for RX at a time.

I will come back with the results.
