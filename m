From: Erik Hugne <erik.hugne@ericsson.com>
Subject: Re: [RFC PATCH net-next (V2, RESENT)] ipv6: Queue fragments per
 interface for multicast/link-local addresses.
Date: Mon, 18 Feb 2013 14:19:01 +0100
Message-ID: <20130218131901.GA24346@eerihug-hybrid.ki.sw.ericsson.se>
References: <511F1E03.9010205@linux-ipv6.org>
 <511FB776.8000901@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: netdev <netdev@vger.kernel.org>, netfilter-devel@vger.kernel.org
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw1.ericsson.se ([193.180.251.45]:45683 "EHLO
	mailgw1.ericsson.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751512Ab3BRNWV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Feb 2013 08:22:21 -0500
Content-Disposition: inline
In-Reply-To: <511FB776.8000901@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Feb 17, 2013 at 01:44:38AM +0900, YOSHIFUJI Hideaki wrote:
> We should queue fragments for the same link-local address on
> different interfaces (e.g. fe80::1%eth0 and fe80::1%eth1) to the
> different queue, because of nature of addressing architecture.
> 
> Similarly, we should queue fragments for multicast on different
> interface to the different queue.  This is okay because
> application joins group on speicific interface, and multicast
> traffic is expected only on that interface.
>

Your patch does solve the reassembly problem when macvlans are defined, thanks!

A tad unrelated, but i think there's still some ipv6 multicast filtering 
work to be done in the macvlan driver. If you for example join an all scope 
mcast address, ff09::1 on macvlan 0 it will implicitly be 'joined' on all 
other macvlans aswell..

I can buy that linklocal multicast packets are cloned out to all macvlan devices,
but if a specific prefix is joined on one of them, i dont think it's correct that
all sibling devices should receive that traffic, unless they asked for it.

//E
