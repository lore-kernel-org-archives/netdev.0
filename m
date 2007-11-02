From: Simon Horman <horms@verge.net.au>
Subject: Re: [patch 2/2] ipvs: Syncrhonise Closing of Connections
Date: Fri, 2 Nov 2007 09:53:49 +0900
Message-ID: <20071102005348.GA20398@verge.net.au>
References: <20071101092818.083169402@vergenet.net> <20071101093022.688977274@vergenet.net> <Pine.LNX.4.58.0711020119580.2992@u.domain.uli>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: lvs-devel@linuxvirtualserver.org, netdev@vger.kernel.org,
	Wensong Zhang <wensong@linux-vs.org>,
	"Rumen G. Bogdanovski" <rumen@voicecho.com>,
	Graeme Fowler <graeme@graemef.net>,
	Joseph Mack NA3T <jmack@wm7d.net>,
	"David S. Miller" <davem@davemloft.net>
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from koto.vergenet.net ([210.128.90.7]:40405 "EHLO koto.vergenet.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752028AbXKBAxx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Nov 2007 20:53:53 -0400
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.58.0711020119580.2992@u.domain.uli>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 02, 2007 at 01:36:07AM +0200, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Thu, 1 Nov 2007, Simon Horman wrote:
> 
> > --- net-2.6.orig/net/ipv4/ipvs/ip_vs_sync.c	2007-11-01 18:17:55.000000000 +0900
> > +++ net-2.6/net/ipv4/ipvs/ip_vs_sync.c	2007-11-01 18:20:30.000000000 +0900
> > @@ -332,7 +332,7 @@ static void ip_vs_process_message(const 
> >  					    s->daddr, s->dport,
> >  					    flags, dest);
> >  			if (dest)
> 
> 	Is that correct? Sorry, I was flooded with different versions
> of this patch and I'm not sure if it is the final one.
> 
> > -				atomic_dec(&dest->refcnt);
> > +				ip_vs_dest_get(dest);
> >  			if (!cp) {
> >  				IP_VS_ERR("ip_vs_conn_new failed\n");
> >  				return;

The ip_vs_dest_get() call shouldn't be there.
I'll double check the rest of the patch.

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

