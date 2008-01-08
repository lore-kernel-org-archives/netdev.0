From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 3/4] [XFRM]: Kill some bloat
Date: Tue, 8 Jan 2008 03:05:29 +0100
Message-ID: <20080108020529.GC16156@one.firstfloor.org>
References: <E1JBJOR-0000jO-00@gondolin.me.apana.org.au> <20080105.231658.168081302.davem@davemloft.net> <p73sl19qi6o.fsf@bingen.suse.de> <20080107.175458.127194310.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: andi@firstfloor.org, herbert@gondor.apana.org.au,
	ilpo.jarvinen@helsinki.fi, netdev@vger.kernel.org, acme@redhat.com,
	paul.moore@hp.com, latten@us.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:50704 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752407AbYAHCDJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jan 2008 21:03:09 -0500
Content-Disposition: inline
In-Reply-To: <20080107.175458.127194310.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 07, 2008 at 05:54:58PM -0800, David Miller wrote:
> From: Andi Kleen <andi@firstfloor.org>
> Date: Tue, 08 Jan 2008 01:23:11 +0100
> 
> > David Miller <davem@davemloft.net> writes:
> > 
> > > Similarly I question just about any inline usage at all in *.c files
> > 
> > Don't forget the .h files. Especially a lot of stuff in tcp.h should
> > be probably in some .c file and not be inline.
> 
> I explicitly left them out.
> 
> Most of them are abstractions of common 2 or 3 instruction
> calculations, and thus should stay inline.

Definitely not in tcp.h. It has quite a lot of very long functions, of
which very few really need to be inline: (AFAIK the only one where 
it makes really sense is tcp_set_state due to constant evaluation; 
although I never quite understood why the callers just didn't 
call explicit functions to do these actions) 

% awk '  { line++ } ; /^{/ { start = line } ; /^}/ { n++; r += line-start-2; } ; END { print r/n }' < include/net/tcp.h 
9.48889

The average function length is 9 lines.

-Andi

