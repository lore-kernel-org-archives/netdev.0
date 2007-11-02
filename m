From: Rumen Bogdanovski <rumen@voicecho.com>
Subject: Re: [lvs-devel] [patch 2/2] ipvs: Syncrhonise Closing of
	Connections
Date: Fri, 02 Nov 2007 11:47:20 +0200
Message-ID: <1193996840.5339.5.camel@lappy>
References: <20071101092818.083169402@vergenet.net>
	 <20071101093022.688977274@vergenet.net>
	 <Pine.LNX.4.58.0711020119580.2992@u.domain.uli>
	 <20071102005348.GA20398@verge.net.au>
Reply-To: rumen@voicecho.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Julian Anastasov <ja@ssi.bg>, Wensong Zhang <wensong@linux-vs.org>,
	netdev@vger.kernel.org, Graeme Fowler <graeme@graemef.net>,
	Joseph Mack NA3T <jmack@wm7d.net>,
	"David S. Miller" <davem@davemloft.net>
To: LVS Development mailing list <lvs-devel@linuxvirtualserver.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.perfora.net ([74.208.4.194]:55476 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752641AbXKBJr0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Nov 2007 05:47:26 -0400
In-Reply-To: <20071102005348.GA20398@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I should have been very tired to miss this one when I looked at the
patch... 
I looked again in the version I have tested. For some
reason/net/ipv4/ipvs/ip_vs_sync.c is not patched at all, this is what I
have missed.

Rumen

On Fri, 2007-11-02 at 09:53 +0900, Simon Horman wrote:
> On Fri, Nov 02, 2007 at 01:36:07AM +0200, Julian Anastasov wrote:
> > 
> > 	Hello,
> > 
> > On Thu, 1 Nov 2007, Simon Horman wrote:
> > 
> > > --- net-2.6.orig/net/ipv4/ipvs/ip_vs_sync.c	2007-11-01 18:17:55.000000000 +0900
> > > +++ net-2.6/net/ipv4/ipvs/ip_vs_sync.c	2007-11-01 18:20:30.000000000 +0900
> > > @@ -332,7 +332,7 @@ static void ip_vs_process_message(const 
> > >  					    s->daddr, s->dport,
> > >  					    flags, dest);
> > >  			if (dest)
> > 
> > 	Is that correct? Sorry, I was flooded with different versions
> > of this patch and I'm not sure if it is the final one.
> > 
> > > -				atomic_dec(&dest->refcnt);
> > > +				ip_vs_dest_get(dest);
> > >  			if (!cp) {
> > >  				IP_VS_ERR("ip_vs_conn_new failed\n");
> > >  				return;
> 
> The ip_vs_dest_get() call shouldn't be there.
> I'll double check the rest of the patch.
> 

