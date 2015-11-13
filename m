From: Phil Sutter <phil@nwl.cc>
Subject: Re: [iproute PATCH 05/12] ip{,6}tunnel: align do_tunnels_list() a bit
Date: Fri, 13 Nov 2015 18:53:03 +0100
Message-ID: <20151113175303.GC22380@orbit.nwl.cc>
References: <1447434545-32182-1-git-send-email-phil@nwl.cc>
 <1447434545-32182-6-git-send-email-phil@nwl.cc>
 <063D6719AE5E284EB5DD2968C1650D6D1CBD1126@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemming@brocade.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:60480 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932651AbbKMRxG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Nov 2015 12:53:06 -0500
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CBD1126@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 13, 2015 at 05:30:10PM +0000, David Laight wrote:
> From: Phil Sutter
> > Sent: 13 November 2015 17:09
> > In iptunnel, declare loop variables inside the loop as done in
> > ip6tunnel.
> ...
> > @@ -396,14 +396,8 @@ static void print_tunnel(struct ip_tunnel_parm *p)
> > 
> >  static int do_tunnels_list(struct ip_tunnel_parm *p)
> >  {
> > -	char name[IFNAMSIZ];
> > -	unsigned long  rx_bytes, rx_packets, rx_errs, rx_drops,
> > -	rx_fifo, rx_frame,
> > -	tx_bytes, tx_packets, tx_errs, tx_drops,
> > -	tx_fifo, tx_colls, tx_carrier, rx_multi;
> > -	struct ip_tunnel_parm p1;
> > -
> ...
> >  	while (fgets(buf, sizeof(buf), fp) != NULL) {
> > +		char name[IFNAMSIZ];
> >  		int index, type;
> > +		unsigned long rx_bytes, rx_packets, rx_errs, rx_drops,
> > +			rx_fifo, rx_frame,
> > +			tx_bytes, tx_packets, tx_errs, tx_drops,
> > +			tx_fifo, tx_colls, tx_carrier, rx_multi;
> > +		struct ip_tunnel_parm p1;
> >  		char *ptr;
> > +
> 
> Personally I find that just makes it harder to find where the
> variables are defined.

Well, the above aligns the code with ip/ip6tunnel.c in that particular
matter. I'm neither a friend of the old nor the new version, so if
everyone thinks it is better without this patch, I'm fine with changing
ip/ip6tunnel.c accordingly as well.

Looking at the code again, maybe the better option overall would be to
export the whole file reading and stats printing code into a shared
function.

> Since the linux kernel cannot be compiled with -Wshadow declaring
> variables in inner scopes can easily lead to very strange bugs.

Well, since this is not kernel code but iproute2 one, we *could* compile
it with -Wshadow.

Thanks, Phil
