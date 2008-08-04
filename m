From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: Warning when unloading the nf_conntack module (regression?)
Date: Mon, 4 Aug 2008 21:30:21 +0100
Message-ID: <20080804203021.GY28946@ZenIV.linux.org.uk>
References: <20080803143730.7747e9a8@infradead.org> <Pine.LNX.4.64.0808032344510.16818@bizon.gios.gov.pl> <Pine.LNX.4.64.0808042027080.4338@bizon.gios.gov.pl> <Pine.LNX.4.64.0808042039400.4338@bizon.gios.gov.pl> <Pine.LNX.4.64.0808042130570.23688@bizon.gios.gov.pl> <20080804200058.GX28946@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arjan van de Ven <arjan@infradead.org>, netdev@vger.kernel.org,
	kaber@trash.net
To: Krzysztof Oledzki <ole@ans.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:60165 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1764570AbYHDUaZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Aug 2008 16:30:25 -0400
Content-Disposition: inline
In-Reply-To: <20080804200058.GX28946@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 04, 2008 at 09:00:58PM +0100, Al Viro wrote:
> On Mon, Aug 04, 2008 at 09:41:10PM +0200, Krzysztof Oledzki wrote:
> 
> >> BTW: It also happens when I revert my patch:
> >>
> >> sysctl -a|grep net.netfilter
> >>
> >> net.netfilter.nf_conntrack_generic_timeout = 600
> >> net.netfilter.nf_conntrack_generic_timeout = 600
> >
> > And the winner is... 9043476f726802f4b00c96d0c4f418dde48d1304:
> >
> > [PATCH] sanitize proc_sysctl
> 
> Almost definitely problems with registration order ;-/  I'll look into
> that once I get a bit of sleep...

... and registration order it is.  Try adding
	static struct ctl_table empty[1];
	register_sysctl_paths(nf_net_netfilter_sysctl_path, empty);
in netfilter_init() and see if that solves the problem.
