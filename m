From: Guillaume Nault <g.nault@alphalink.fr>
Subject: Re: [PATCH net] ppp: don't override sk->sk_state in pppoe_flush_dev()
Date: Mon, 5 Oct 2015 14:24:59 +0200
Message-ID: <20151005122459.GG2911@alphalink.fr>
References: <b7fbf103cd589741e3938550e7cf0f3684d8951c.1443605079.git.g.nault@alphalink.fr>
 <7045c1dad4647944f61c958511d45fcd@visp.net.lb>
 <20151002175426.GE2911@alphalink.fr>
 <356ca8b8094bb2460c0182c00e120378@visp.net.lb>
 <1444018131.14634.6.camel@mattb-dl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "nuclearcat@nuclearcat.com" <nuclearcat@nuclearcat.com>,
	"core@irc.lg.ua" <core@irc.lg.ua>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"paulus@samba.org" <paulus@samba.org>
To: Matt Bennett <Matt.Bennett@alliedtelesis.co.nz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:44458 "EHLO
	mail-2-cbv2.admin.alphalink.fr" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750935AbbJEMZF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2015 08:25:05 -0400
Content-Disposition: inline
In-Reply-To: <1444018131.14634.6.camel@mattb-dl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 05, 2015 at 04:08:51AM +0000, Matt Bennett wrote:
> Hi, I am seeing this panic occur occasionally however I am unsure how to
> go about reproducing it. Is it enough to simply keep creating and
> tearing down the PPP interface? I can also test and/or investigate this
> issue if a suitable reproduction method is available.
> 
There are at least two issues resulting in similar Oops.

The first one goes with MTU/address/link state updates on the
underlying interface: any such update on an interface used by a
PPPoE connection will generally result in an Oops when releasing the
PPPoE connection. This is fixed by e6740165b8f7 ("ppp: don't override
sk->sk_state in pppoe_flush_dev()").

The second one seems to be trickier. It looks like a race wrt. PADT
message reception. Reproducing the bug will probably require to
generate some PADT flooding to a host that creates and releases PPPoE
connections.
