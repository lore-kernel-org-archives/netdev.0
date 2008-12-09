From: Balazs Scheidler <bazsi@balabit.hu>
Subject: Re: Documentation for IP_TRANSPARENT?
Date: Tue, 09 Dec 2008 14:17:28 +0100
Message-ID: <1228828648.7631.75.camel@bzorp.balabit>
References: <cfd18e0f0811240806w541c85e9gafbcc80e8101f2b2@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: KOVACS Krisztian <hidden@sch.bme.hu>,
	David Miller <davem@davemloft.net>, linux-net@vger.kernel.org,
	netdev <netdev@vger.kernel.org>
To: mtk.manpages@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from support.balabit.hu ([195.70.41.86]:47618 "EHLO lists.balabit.hu"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751914AbYLINRf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Dec 2008 08:17:35 -0500
In-Reply-To: <cfd18e0f0811240806w541c85e9gafbcc80e8101f2b2@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Mon, 2008-11-24 at 11:06 -0500, Michael Kerrisk wrote:
> Hello Krisztian,
> 
> Your 2.6.27 patch adds  the IP_TRANSPARENT socket option.  Could you
> please supply some documentation (plain text is fine) suitable for
> inclusion in the ip(7) man page.

Although it was Krisztian who originally submitted the patches, but I
also did some things about them, so here I gave the documentation part a
spin. 

There are some other related options, that are undocumented right now,
so I tried to give documentation on those as well.

IP_FREEBIND
	Enable binding to IP addresses that do not currently exist. When 
	enabled on a TCP or UDP socket, the bind(2) call referencing a 
	non-existing IP address will succeed. This functionality is useful 
	if the specified IP address is dynamic (e.g. assigned to a PPP device) 
	and is down at the time when the application is trying to bind to it. 
	This setsockopt is the per-socket equivalent to ip_nonlocal_bind sysctl.

IP_TRANSPARENT
	Enable transparent proxying on this socket. This socket option allows 
	the calling application to bind to a non-local IP address and operate
	both as a client and a server with the foreign address as the local 
	endpoint. NOTE: this requires that routing be set up in a way that 
	packets going to the foreign address are routed through the tproxy box. 
	Enabling this socket option requires superuser privileges 
	(more specifically the CAP_NET_ADMIN capability).

	TProxy redirection with the iptables TPROXY target also requires that
	this option be set on the redirected socket.

IP_RECVORIGDSTADDR
	Enables the IP_ORIGDSTADDR ancillary message in recvmsg(2) in which 
	the kernel returns the original destination address of a datagram. The 
	ancillary message contains a "struct sockaddr_in" instance.

-- 
Bazsi


