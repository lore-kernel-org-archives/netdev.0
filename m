From: "Arnaldo Carvalho de Melo" <acme@redhat.com>
Subject: Re: [PATCH][PACKET] Remove unneeded packet_socks_nr variable
Date: Wed, 7 Nov 2007 14:26:35 -0200
Message-ID: <20071107162635.GN27345@ghostprotocols.net>
References: <4731DAA3.7060306@openvz.org> <20071107155004.GI27345@ghostprotocols.net> <20071107155301.GJ27345@ghostprotocols.net> <4731E4CE.6030603@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arnaldo Carvalho de Melo <acme@redhat.com>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:57710 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753021AbXKGQ0n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Nov 2007 11:26:43 -0500
Content-Disposition: inline
In-Reply-To: <4731E4CE.6030603@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Em Wed, Nov 07, 2007 at 07:16:14PM +0300, Pavel Emelyanov escreveu:
> Arnaldo Carvalho de Melo wrote:
> > Em Wed, Nov 07, 2007 at 01:50:04PM -0200, Arnaldo Carvalho de Melo escreveu:
> >> Em Wed, Nov 07, 2007 at 06:32:51PM +0300, Pavel Emelyanov escreveu:
> >>> This one is used only under ifdef PACKET_REFCNT_DEBUG in
> >>> printk and is not needed otherwise. So hide all this stuff
> >>> under the PACKET_REFCNT_DEBUG.
> >>>
> >>> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
> >> Look at sk_refcnt_debug_inc, etc and you'll se a more standard way. I
> >> forgot to make this when making all protocol families use sk_prot, even
> >> if just partially :-)
> > 
> > As a bonus you'll get this information on /proc/net/protocols, removing
> > '-1' from PACKET column for "sockets".
> 
> Hm... I actually thought about this, but I decided that packet
> sockets were not accounted in this way deliberately.
> 
> So, shall I break this "compatibility" (-1 in proc) and provide
> a packet socket number in this file?

Humm, my bad, the sockets column in /proc/net/protocols doesn't come
from prot->socks, it comes from prot->sockets_allocated. But the
suggestion for using sk_refcnt_debug_inc stands, it is there for when we
want to do what the code in pf_packet does: refcount debugging, in fact
that code most probably was copy'n'pasted from other, older protocols.

BTW, IPX also uses this technique, patches are welcome to make it also
use common infrastructure :-)

- Arnaldo
