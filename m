From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: Paper on lookup in Linux.
Date: Mon, 4 Sep 2006 14:53:12 +0200
Message-ID: <17660.8632.602340.514616@robur.slu.se>
References: <17660.4445.36266.884445@robur.slu.se>
	<200609041424.26564.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>, netdev@vger.kernel.org,
	snilsson@nada.kth.se
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.slu.se ([130.238.96.70]:2504 "EHLO mx1.slu.se")
	by vger.kernel.org with ESMTP id S964859AbWIDMxP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Sep 2006 08:53:15 -0400
To: Andi Kleen <ak@suse.de>
In-Reply-To: <200609041424.26564.ak@suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Andi Kleen writes:
 > On Monday 04 September 2006 13:43, Robert Olsson wrote:
 > > 
 > > Hello.
 > > 
 > > People on this list might find this paper interesting:
 > > http://www.csc.kth.se/~snilsson/public/papers/trash/
 > 
 > Looks nice. Have you looked at using it for local TCP/UDP socket
 > lookups too or would that be part of the "unified flow cache"? 


 No we haven't put struct socket in the leafs (result node) yet we just kept 
 dst entries and some stateful flow variables that we used for active GC 
 and flow logging so far. So 128 bit flow version of the dst hash. It would 
 have taken a lot a of more work and we wanted to get this paper out. Also 
 ip_route_input is not the place have the lookup if we with unified include 
 ip6. So we focused on designing and building the lookup core.


 Cheers.
					--ro

 struct leaf {
        __u32 key[LPK];
        unsigned long parent;
        void *obj;  /* Generic leaf object */
        __u32 state;
        unsigned int len;
        int iif;
        struct timeval start;
        struct rcu_head rcu;
};
