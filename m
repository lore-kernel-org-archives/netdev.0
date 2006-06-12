From: David Miller <davem@davemloft.net>
Subject: Re: [ PATCH 2.6.17-rc6 1/1] udp.c: counting InDatagrams which are
 never delivered
Date: Sun, 11 Jun 2006 23:49:05 -0700 (PDT)
Message-ID: <20060611.234905.35014718.davem@davemloft.net>
References: <20060611.212913.70218067.davem@davemloft.net>
	<E1FpfkX-0000EL-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gerrit@erg.abdn.ac.uk, netdev@vger.kernel.org, kaber@coreworks.de,
	jmorris@namei.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:35238
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1750700AbWFLGs6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Jun 2006 02:48:58 -0400
To: herbert@gondor.apana.org.au
In-Reply-To: <E1FpfkX-0000EL-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Mon, 12 Jun 2006 16:18:09 +1000

> David Miller <davem@davemloft.net> wrote:
> > 
> > Probably a better way to handle this is to correct the
> > INDATAGRAMS value by decrementing it when we notice that
> > the checksum is incorrect in a deferred manner.
> 
> I think sunrpc should instead increment the appropriate counters directly
> as otherwise checksum errors won't be recorded correctly for sunrpc packets.

Yeah.  Good point.  But how much protocol internals do we want to
slide into the ->data_ready() callbacks of such layers?  That's ugly
and something we should try to avoid.
