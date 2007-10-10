From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] more robust inet range checking
Date: Wed, 10 Oct 2007 16:31:08 -0700 (PDT)
Message-ID: <20071010.163108.67884821.davem@davemloft.net>
References: <20071010141530.GA10661@iris.sw.ru>
	<20071010100939.0783febb@freepuppy.rosehill>
	<470D26E4.2050708@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, den@openvz.org,
	aarapov@redhat.com, netdev@vger.kernel.org
To: brian.haley@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58814
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756214AbXJJXbG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Oct 2007 19:31:06 -0400
In-Reply-To: <470D26E4.2050708@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Brian Haley <brian.haley@hp.com>
Date: Wed, 10 Oct 2007 15:24:20 -0400

> Stephen Hemminger wrote:
> > --- a/net/ipv4/udp.c	2007-10-10 08:27:00.000000000 -0700
> > +++ b/net/ipv4/udp.c	2007-10-10 09:44:35.000000000 -0700
> > @@ -147,13 +147,13 @@ int __udp_lib_get_port(struct sock *sk, 
> >  	write_lock_bh(&udp_hash_lock);
> >  
> >  	if (!snum) {
> > -		int i;
> > -		int low = sysctl_local_port_range[0];
> > -		int high = sysctl_local_port_range[1];
> > +		int i, range[2];
> >  		unsigned rover, best, best_size_so_far;
> 
> Should these be signed ints?  They're the only ones that are unsigned, 
> but I don't know why.

They have just been hacked inconsistently over the years,
that's the only reason these types are like that.

> > --- a/net/sctp/protocol.c	2007-10-10 08:27:00.000000000 -0700
> > +++ b/net/sctp/protocol.c	2007-10-10 09:58:21.000000000 -0700
> > @@ -1173,7 +1173,6 @@ SCTP_STATIC __init int sctp_init(void)
> >  	}
> >  
> >  	spin_lock_init(&sctp_port_alloc_lock);
> > -	sctp_port_rover = sysctl_local_port_range[0] - 1;
> 
> I think you can remove the port_rover definition in sctp/structs.h and 
> also the lock that protects it.  Patch below for that which can be 
> applied on-top of yours.
> 
> -Brian
> 
> 
> Remove SCTP port_rover and port_alloc_lock as they're no longer required.
> 
> Signed-off-by: Brian Haley <brian.haley@hp.com>

I like this range checking change, someone please resubmit with
Brian's nits and this SCTP cleanup integrated on top.

I'll probably submit this to stable since it fixes the potential
divide by zero, so test whatever you post :-)

Thanks!
