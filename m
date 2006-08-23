From: "H. Peter Anvin" <hpa@zytor.com>
Subject: ProxyARP and IPSec
Date: Tue, 22 Aug 2006 17:31:56 -0700
Message-ID: <44EBA1FC.5000801@zytor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from terminus.zytor.com ([192.83.249.54]:52391 "EHLO
	terminus.zytor.com") by vger.kernel.org with ESMTP id S1751198AbWHWAcA
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Aug 2006 20:32:00 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello all,

I am having a puzzlement combining ProxyARP and IPsec.  Specificially, I 
want to take a single address from a local LAN and extend it via IPsec 
to another site.

Unfortunately IPsec tunnels, unlike all other tunnels, don't have 
pseudo-devices associated with them.  I understand this to be from 
desire of uniformity with the other modes of IPsec, but this is one of 
many cases where it causes problems.

Specifically, Linux will not ProxyARP for an address unless it has a 
route for it, *and* that route either has a DNAT marking or points to a 
different interface than the input interface:

net/ipv4/arp.c:

    855                  } else if (IN_DEV_FORWARD(in_dev)) {
    856                          if ((rt->rt_flags&RTCF_DNAT) ||
    857                              (addr_type == RTN_UNICAST  && 
rt->u.dst.dev != dev &&
^^^^^^^^^^^^^^^^^^^^
    858                               (arp_fwd_proxy(in_dev, rt) || 
pneigh_lookup(&arp_tbl, &tip, dev, 0)))) {

However, since IPsec tunnels don't have interfaces associated with it, 
the route to the other side of the IPsec tunnel with point to the same 
interface (there is, elsewhere, a security policy associated with the 
address), and this selection will fail.

Does anyone know of a trick around this issue?

	-hpa
