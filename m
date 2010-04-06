From: "Steven J. Magnani" <steve@digidescorp.com>
Subject: RE: [PATCH] [V3] Add non-Virtex5 support for LL TEMAC driver
Date: Tue, 06 Apr 2010 10:08:02 -0500
Message-ID: <1270566482.3949.4.camel@iscandar.digidescorp.com>
References: <d9134316-bd07-46a8-91d4-c30f27baeb60@SG2EHSMHS007.ehs.local>
	 <1270502993.9013.36.camel@edumazet-laptop>
	 <7a42d507-bf50-40f3-a2a0-8de682b314d7@SG2EHSMHS017.ehs.local>
Reply-To: steve@digidescorp.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org, grant.likely@secretlab.ca,
	jwboyer@linux.vnet.ibm.com, john.williams@petalogix.com,
	michal.simek@petalogix.com, John Tyner <jtyner@cs.ucr.edu>
To: John Linn <John.Linn@xilinx.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.digidescorp.com ([66.244.163.200]:36391 "EHLO
	digidescorp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751665Ab0DFPIJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Apr 2010 11:08:09 -0400
Received: from [10.10.6.102] by digidescorp.com (Cipher SSLv3:RC4-MD5:128) (MDaemon PRO v10.1.1)
	with ESMTP id md50001246428.msg
	for <netdev@vger.kernel.org>; Tue, 06 Apr 2010 10:08:08 -0500
In-Reply-To: <7a42d507-bf50-40f3-a2a0-8de682b314d7@SG2EHSMHS017.ehs.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-04-05 at 15:33 -0600, John Linn wrote:
> > > +/* Align the IP data in the packet on word boundaries as MicroBlaze
> > > + * needs it.
> > > + */
> > > +
> > >  #define XTE_ALIGN       32
> > > -#define BUFFER_ALIGN(adr) ((XTE_ALIGN - ((u32) adr)) % XTE_ALIGN)
> > > +#define BUFFER_ALIGN(adr) ((34 - ((u32) adr)) % XTE_ALIGN)
> > >
> > 
> > Very interesting way of doing this, but why such convoluted thing ?
> 
> Grant might have insight into why this started this way, I just updated to help with MicroBlaze alignment.
> 
> > 
> > Because of the % 32, this is equivalent to :
> > 
> > #define BUFFER_ALIGN(adr) ((2 - ((u32) adr)) % XTE_ALIGN)
> > 
> > But wait, dont we recognise the magic constant NET_IP_ALIGN ?
> > 
> > So, I ask, cant you use netdev_alloc_skb_ip_align() in this driver ?
> > 

That should work. I switched to that in the older xilinx_lltemac driver
without any problem. 

------------------------------------------------------------------------
 Steven J. Magnani               "I claim this network for MARS!
 www.digidescorp.com              Earthling, return my space modulator!"

 #include <standard.disclaimer>



