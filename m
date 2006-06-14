From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 0/2] NET: Accurate packet scheduling for ATM/ADSL
Date: Wed, 14 Jun 2006 08:06:06 -0400
Message-ID: <1150286766.5233.15.camel@jzny2>
References: <1150278004.26181.35.camel@localhost.localdomain>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: hawk@diku.dk, russell-tcatm@stuart.id.au, lartc@mailman.ds9a.nl,
	netdev@vger.kernel.org, Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx03.cybersurf.com ([209.197.145.106]:53913 "EHLO
	mx03.cybersurf.com") by vger.kernel.org with ESMTP id S1751260AbWFNMGP
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Jun 2006 08:06:15 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx03.cybersurf.com with esmtp (Exim 4.30)
	id 1FqU8U-00082D-4Q
	for netdev@vger.kernel.org; Wed, 14 Jun 2006 08:06:14 -0400
To: Jesper Dangaard Brouer <hawk@comx.dk>
In-Reply-To: <1150278004.26181.35.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


I have taken linux-kernel off the list.

Russell's site is inaccessible to me (I actually think this is related
to some DNS issues i may be having) and your masters is too long to
spend 2 minutes and glean it; so heres a question or two for you:

- Have you tried to do a long-lived session such as a large FTP and 
seen how far off the deviation was? That would provide some interesting
data point.
- To be a devil's advocate (and not claim there is no issue), where do
you draw the line with "overhead"? 
Example the smallest ethernet packet is 64 bytes of which 14 bytes are
ethernet headers ("overhead" for IP) - and this is not counting CRC etc.
If you were to set an MTU of say 64 bytes and tried to do a http or ftp,
how accurate do you think the calculation would be? I would think not
very different.
Does it matter if it is accurate on the majority of the cases?
- For further reflection: Have you considered the case where the rate
table has already been considered on some link speed in user space and
then somewhere post-config the physical link speed changes? This would
happen in the case where ethernet AN is involved and the partner makes
some changes (use ethtool). 

I would say the last bullet is a more interesting problem than a corner
case of some link layer technology that has high overhead.
Your work would be more interesting if it was generic for many link
layers instead of just ATM.


cheers,
jamal

On Wed, 2006-14-06 at 11:40 +0200, Jesper Dangaard Brouer wrote:
> The Linux traffic's control engine inaccurately calculates
> transmission times for packets sent over ADSL links.  For
> some packet sizes the error rises to over 50%.  This occurs
> because ADSL uses ATM as its link layer transport, and ATM
> transmits packets in fixed sized 53 byte cells.
> 
> The following patches to iproute2 and the kernel add an
> option to calculate traffic transmission times over all
> ATM links, including ADSL, with perfect accuracy.
> 
> A longer presentation of the patch, its rational, what it
> does and how to use it can be found here:
>    http://www.stuart.id.au/russell/files/tc/tc-atm/
> 
> A earlier version of the patch, and a _detailed_ empirical
> investigation of its effects can be found here:
>    http://www.adsl-optimizer.dk/
> 
> The patches are both backwards and forwards compatible.
> This means unpatched kernels will work with a patched
> version of iproute2, and an unpatched iproute2 will work
> on patches kernels.
> 
> 
> This is a combined effort of Jesper Brouer and Russell Stuart,
> to get these patches into the upstream kernel.
> 
> Let the discussion start about what we need to change to get this
> upstream?
> 
> We see this as a feature enhancement, as thus hope that it can be
> queued in davem's net-2.6.18.git tree.
> 
> ---
> Regards,
>  Jesper Brouer & Russell Stuart.
> 

