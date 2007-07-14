From: =?iso-8859-1?q?R=E9mi_Denis-Courmont?= <rdenis@simphalempin.com>
Subject: Re: No cmsg for SOCK_STREAM?
Date: Sat, 14 Jul 2007 19:38:11 +0300
Message-ID: <200707141938.12028@auguste.remlab.net>
References: <C63E4CE2-57E4-446C-B7B0-80D9E506A83C@mac.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-net@vger.kernel.org, Linux NetDev <netdev@vger.kernel.org>
To: Daniel Schaffrath <daniel.schaffrath@mac.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from poy.chewa.net ([194.242.114.73]:4850 "EHLO poy.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755281AbXGNQiU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Jul 2007 12:38:20 -0400
In-Reply-To: <C63E4CE2-57E4-446C-B7B0-80D9E506A83C@mac.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le samedi 14 juillet 2007, Daniel Schaffrath a =E9crit :
> 'man 7 ip' sais that IP_RECVOPTS is not supported for SOCK_STREAM
> sockets.
>
> But what if for debugging/measuring purposes I wanted to record the
> route of the datagrams containing the stream segments? Are there any
> other ways to get the IP options? Like a second raw socket to deliver
> cmsgs to user space and later resubmit for kernel TCP processing and
> normal delivery to application -- if that is possible at all.

The STREAM does not return data on a per-packet basis, so it would be=20
total non-sense to have IP_RECVOPTS on STREAM sockets. What would the=20
kernel do when there is re-assembly before delivery to userland, or if=20
a retransmitted segment has different options?!

=46YI, the "advanced" socket API (for IPv6) consistently notes that=20
sending/receiving IP(v6) options per-packet is only defined for DGRAM=20
and RAW sockets.

You have to raw sockets, or better yet, BPF to do this.

--=20
R=E9mi Denis-Courmont
http://www.remlab.net/
