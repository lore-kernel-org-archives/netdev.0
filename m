From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [RFD][PATCH] typhoon and core sample for folding away VLAN
 stuff
Date: Wed, 12 Apr 2006 13:51:43 -0700 (PDT)
Message-ID: <20060412.135143.29962858.davem@davemloft.net>
References: <200604111517.37215.netdev@axxeo.de>
	<200604122132.46113.ioe-lkml@rameria.de>
	<443D5E9E.80002@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ioe-lkml@rameria.de, netdev@axxeo.de, vda@ilport.com.ua,
	dave@thedillows.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:54230
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932233AbWDLUwY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Apr 2006 16:52:24 -0400
To: greearb@candelatech.com
In-Reply-To: <443D5E9E.80002@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ben Greear <greearb@candelatech.com>
Date: Wed, 12 Apr 2006 13:10:06 -0700

> What is the reasoning for this change?  Is the compiler
> able to optomize the right-hand-side to a constant with your
> change in place?
> 
> > -	if (veth->h_vlan_proto != __constant_htons(ETH_P_8021Q)) {
> > +	if (veth->h_vlan_proto != htons(ETH_P_8021Q)) {
> >  		return -EINVAL;
> >  	}

As a policy, Ben, we only use __constant_htons() in compile
time initializers of data structures.  Otherwise we use the
normal htons().

That's why.
