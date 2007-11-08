From: Andreas Gruenbacher <agruen@suse.de>
Subject: Re: Why does a connect to IPv6 LLA address fail ?
Date: Thu, 8 Nov 2007 19:01:59 +0100
Message-ID: <200711081901.59334.agruen@suse.de>
References: <20071107094007.GA15575@pingi.kke.suse.de> <20071107112838.GA22180@dhcp79.suse.cz> <4732151B.70309@hp.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jiri Bohac <jbohac@suse.cz>, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org, kkeil@suse.de
To: Vlad Yasevich <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.suse.de ([195.135.220.2]:58007 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754564AbXKHSCC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Nov 2007 13:02:02 -0500
In-Reply-To: <4732151B.70309@hp.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 07 November 2007 20:42, Vlad Yasevich wrote:
> The reason is that 2 different hosts may have the same link-local
> address as long as they are on different links.  If the sender is
> connected to both links then it may send the packet to the wrong
> destination.

Good point.

What's confusing is that connect(2) fails even if the host itself has the 
specified address. This isn't necessary.

What's even more confusing is that the kernel doesn't seem to honor the 
interface in all cases: with
   fe80::20f:20ff:fe3b:e9c3 on eth0 and
   ::1 on lo,
I get the following:

  ping6 fe80::20f:20ff:fe3b:e9c3		fails with EINVAL
  ping6 fe80::20f:20ff:fe3b:e9c3%eth0		succeeds
  ping6 fe80::20f:20ff:fe3b:e9c3%lo		succeeds

At least the last ping should fail, shouldn't it?

> A different and some might say 'better' alternative is to define a
> default link.  Thus when the zone id is not specified the default is used.
> This will work fine for link-scoped addresses.  A default zone would also
> need to be defined for other scopes as well.  That's just one idea.

I think at least for host with only one link (in addition to loopback), 
selecting that link for non-local addresses would make sense.

Thanks,
Andreas
