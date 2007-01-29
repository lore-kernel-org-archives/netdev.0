From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] IPv6: Implement RFC 4429 Optimistic Duplicate Address Detection
Date: Mon, 29 Jan 2007 16:30:13 -0500
Message-ID: <20070129213013.GA26841@hmsreliant.homelinux.net>
References: <20070125133340.GA8891@hmsreliant.homelinux.net> <45B8E60B.7080809@hp.com> <20070125194500.GB8891@hmsreliant.homelinux.net> <20070126.091331.22638713.yoshfuji@linux-ipv6.org> <20070126191817.GC15916@hmsreliant.homelinux.net> <45BA6478.4020304@hp.com> <20070126213524.GD15916@hmsreliant.homelinux.net> <45BA75D1.6040005@hp.com> <20070129163447.GB21938@hmsreliant.homelinux.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: YOSHIFUJI Hideaki / =?utf-8?B?5ZCJ6Jek6Iux5piO?=
	<yoshfuji@linux-ipv6.org>, sri@us.ibm.com, davem@davemloft.net,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	kaber@coreworks.de, netdev@vger.kernel.org
To: Vlad Yasevich <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:4783 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752056AbXA2Vri (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Jan 2007 16:47:38 -0500
Content-Disposition: inline
In-Reply-To: <20070129163447.GB21938@hmsreliant.homelinux.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Quick reality check here.  In thinking about how best to go about this
redirection of frames to the default router, based on Dave M.s input, I think
that the best solution would be in ndisc_send_ns.  What I was thinking was that
in ndisc_send_ns, we already detect if a source address is optimistic and squash
the transmission of the frame there.  What if in addition to that supression, we
also immediately update the neighbor cache entry for the requested host, to
reflect the mac address of the default gateway.  That way any dst cache lookups
for hosts we don't know the true link layer address for will get redirected to
the default gateway.  Then any ICMP redirect messages from the router will fix
those entires up for us.  Later, when DAD completes, normal neighbour garbage
collection and/or timeouts will sort out the neighbor cache entries for us.  Or
alternatively we could flush the cache entirely, or scan the cache for entires
that match the lladdr of the default gateway and do a selective purge.  I'm
going to start implementing this, but I wanted to post it here to make sure I'm
not missing anything really big on this idea.

Thanks & Regards
Neil

