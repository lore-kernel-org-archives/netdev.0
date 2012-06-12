From: Thomas Graf <tgraf@infradead.org>
Subject: Re: [PATCHv2 net-next] ipv4: Add interface option to enable routing
 of 127.0.0.0/8
Date: Tue, 12 Jun 2012 15:50:19 -0400
Message-ID: <20120612195019.GM28598@canuck.infradead.org>
References: <20120608101859.GH32152@canuck.infradead.org>
 <20120611.165740.419299184892679723.davem@davemloft.net>
 <20120612104401.GH28598@canuck.infradead.org>
 <4FD786B8.3030205@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, tgraf@suug.ch,
	David Miller <davem@davemloft.net>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:44365 "EHLO
	merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751955Ab2FLTuX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jun 2012 15:50:23 -0400
Content-Disposition: inline
In-Reply-To: <4FD786B8.3030205@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 12, 2012 at 11:13:12AM -0700, Rick Jones wrote:
> I'd go beyond "traditionally forbidden" and call it something
> considered fundamental.  That 127.0.0.1 (et al) can only be reached
> by entities on the same system is rather deeply ingrained in the
> collective consciousness after 30-odd years.

I absolutely agree with regard to 127.0.0.1 but I do not fully
agree with regard to 127/8 in general.

> This change would make 127/8 a de facto RFC 1918 address right?  It
> would not be publicly routable.  Are there actually entities who
> have exhausted 10/8, 172.16/12 and 192.168/16?

This is not about enabling 127/8 to become publicly routeable.
This is about enabling 127/8 for host internal routing, f.e.
virtual bridges, ifb devices, or dummy devices.

The problem with 10/8, 172.162/12 and 192.168/16 is that these
ranges are often in use by VPNs and thus unavailable. None of these
addresses are guaranteed to be available on a random system.

An example for such usage would be virtualization where you want
to assign addresses to guests which are guaranteed to be available
in host scope as well.

Yes, if someone enables this on a publicly facing interface that
will enable the possibility to violate the RFC but he might as well
do that by using a raw socket.

> Are there any other stacks which can do this, or would this be an
> "RFC 1918" network between (newer)Linux systems only?  (Assuming
> non-newer-linux-based routers would be happy with it)

AFAIK none but I could be wrong. Again, this option is not intended
to be used on any public interfaces. However, if you want to enable
this in your own private network, fine with me again.
