From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [RFD][PATCH] typhoon and core sample for folding away VLAN
 stuff
Date: Wed, 12 Apr 2006 13:23:22 -0700
Message-ID: <20060412132322.7786111b@localhost.localdomain>
References: <200604071628.30486.vda@ilport.com.ua>
	<200604111502.52302.vda@ilport.com.ua>
	<200604111517.37215.netdev@axxeo.de>
	<200604122132.46113.ioe-lkml@rameria.de>
	<443D5E9E.80002@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Ingo Oeser <ioe-lkml@rameria.de>, Ingo Oeser <netdev@axxeo.de>,
	Denis Vlasenko <vda@ilport.com.ua>,
	Dave Dillow <dave@thedillows.org>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:430 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932222AbWDLUY5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Apr 2006 16:24:57 -0400
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <443D5E9E.80002@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 12 Apr 2006 13:10:06 -0700
Ben Greear <greearb@candelatech.com> wrote:

> What is the reasoning for this change?  Is the compiler
> able to optomize the right-hand-side to a constant with your
> change in place?
> 
> > -	if (veth->h_vlan_proto != __constant_htons(ETH_P_8021Q)) {
> > +	if (veth->h_vlan_proto != htons(ETH_P_8021Q)) {
> >  		return -EINVAL;
> >  	}

Read the source, the macro handles it.

For i386:
	htons maps to __cpu_to_be16
	cpu_to_be16 maps to swab16 which is defined in swab.h

#  define __swab16(x) \
(__builtin_constant_p((__u16)(x)) ? \
 ___swab16((x)) : \
 __fswab16((x)))


