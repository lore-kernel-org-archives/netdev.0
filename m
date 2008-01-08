From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/4] [XFRM]: Kill some bloat
Date: Mon, 07 Jan 2008 19:37:00 -0800 (PST)
Message-ID: <20080107.193700.159646842.davem@davemloft.net>
References: <p73sl19qi6o.fsf@bingen.suse.de>
	<20080107.175458.127194310.davem@davemloft.net>
	<20080108020529.GC16156@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, ilpo.jarvinen@helsinki.fi,
	netdev@vger.kernel.org, acme@redhat.com, paul.moore@hp.com,
	latten@us.ibm.com
To: andi@firstfloor.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54351
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750768AbYAHDhB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jan 2008 22:37:01 -0500
In-Reply-To: <20080108020529.GC16156@one.firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andi Kleen <andi@firstfloor.org>
Date: Tue, 8 Jan 2008 03:05:29 +0100

> On Mon, Jan 07, 2008 at 05:54:58PM -0800, David Miller wrote:
> > I explicitly left them out.
> > 
> > Most of them are abstractions of common 2 or 3 instruction
> > calculations, and thus should stay inline.
> 
> Definitely not in tcp.h. It has quite a lot of very long functions, of
> which very few really need to be inline: (AFAIK the only one where 
> it makes really sense is tcp_set_state due to constant evaluation; 
> although I never quite understood why the callers just didn't 
> call explicit functions to do these actions) 
> 
> % awk '  { line++ } ; /^{/ { start = line } ; /^}/ { n++; r += line-start-2; } ; END { print r/n }' < include/net/tcp.h 
> 9.48889
> 
> The average function length is 9 lines.

The vast majority of them are one, two, and three liners.

There are about 4 or 5 inlines in there are in fact large and perhaps
should be removed, and these puff up your average.
