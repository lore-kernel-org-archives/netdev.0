From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: Multicast socket behaviour?
Date: Wed, 13 Aug 2008 07:19:50 -0400
Message-ID: <20080813111950.GA2034@hmsreliant.think-freely.org>
References: <loom.20080813T082132-707@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Daniel Ng <daniel_ng11@lycos.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:2906 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752337AbYHMLT7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Aug 2008 07:19:59 -0400
Content-Disposition: inline
In-Reply-To: <loom.20080813T082132-707@post.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 13, 2008 at 08:21:58AM +0000, Daniel Ng wrote:
> Hi,
> 
> The below C code registers the socket with the multicast group 'HELLO_GROUP':
> 
>     mreq.imr_multiaddr.s_addr=inet_addr(HELLO_GROUP);
>     mreq.imr_address.s_addr=htonl(INADDR_ANY);
> 
>     mreq.imr_ifindex = if_nametoindex("ppp1");
> 
>     if (setsockopt(fd,IPPROTO_IP,IP_ADD_MEMBERSHIP,&mreq,sizeof(mreq)) < 0) {
>         perror("setsockopt");
>         exit(1);
>     }
> 
> I understand that if 'INADDR_ANY' is used, it is up to the kernel to decide 
> what action to take.
> 
> >From my experiments, it seems that the interface corresponding to the 
> highest '224.0.0.0' entry in the routing table is used.
> 
> Would someone please explain why this is so? 
> 
> How difficult would it be to have the kernel join the HELLO_GROUP on *all* 
> available multicast-capable interfaces? Why isn't this currently implemented?
> 
> I'm using 2.6.14.
> 
> Cheers,
> Daniel
> 

I had this same confusion on netdev a few weeks ago:
http://marc.info/?l=linux-netdev&m=121580189427089&w=2

Its working as it should, allbeit somewhat counter-intuitively.  Although there
may be a bug in your kernel, you're several releases back.

Neil


-- 
/****************************************************
 * Neil Horman <nhorman@tuxdriver.com>
 * Software Engineer, Red Hat
 ****************************************************/
