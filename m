From: Jouni Malinen <j@w1.fi>
Subject: Re: [Ipw2100-devel] ipw2100: race between isr_indicate_associated
	and rx path
Date: Mon, 23 Feb 2009 20:08:01 +0200
Message-ID: <20090223180801.GA29290@jm.kir.nu>
References: <200901211734.48625.helmut.schaa@gmail.com> <200901271521.24395.helmut.schaa@gmail.com> <200902051511.31268.helmut.schaa@gmail.com> <200902231138.58067.helmut.schaa@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "Zhu, Yi" <yi.zhu@intel.com>,
	"ipw2100-devel@lists.sourceforge.net"
	<ipw2100-devel@lists.sourceforge.net>
To: Helmut Schaa <helmut.schaa@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 128-177-27-249.ip.openhosting.com ([128.177.27.249]:52204 "EHLO
	jmalinen.user.openhosting.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754559AbZBWSyc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Feb 2009 13:54:32 -0500
Content-Disposition: inline
In-Reply-To: <200902231138.58067.helmut.schaa@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 23, 2009 at 11:38:57AM +0100, Helmut Schaa wrote:

> Jouni, would you accept a patch for wpa_supplicant that adds some retries
> to l2_packet_send when the network stack returns an error?

Changing l2_packet_send() to do some magic on errors does not sound like
the correct solution here. l2_packet_send() caller might be more
interested in doing something should the send fail. If I understood the
description correctly, it sounds like kernel code is telling user space
that everything is ready and it is even delivering a received frame into
user space. If sending of the reply to this frame is now failing, it
sounds much more like a kernel side issue that should really be fixed
instead of trying to come up with workarounds in user space
applications. If the driver/network stack is not ready to accept
packets, it should not really claim to be.

I did not fully understand the details of the issue and why noop_qdisc
is used at the point when a frame is delivered to user space, so I may
be missing some details here. Anyway, I would highly prefer the kernel
to avoid delivering EAPOL frames into user space if it is not ready to
transmit a response to them.

-- 
Jouni Malinen                                            PGP id EFC895FA
