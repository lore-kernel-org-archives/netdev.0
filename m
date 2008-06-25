From: Eli Cohen <eli@dev.mellanox.co.il>
Subject: Re: [ofa-general] [PATCH] net/inet_lro: remove setting
	skb->ip_summed when not LRO-able
Date: Wed, 25 Jun 2008 15:30:05 +0300
Message-ID: <1214397005.23583.60.camel@mtls03>
References: <OFEBCC17DD.4CE7F0B2-ONC1257473.003ED3DA-C1257473.003EE40F@de.ibm.com>
	 <4862304D.2050306@voltaire.com>
Reply-To: eli@dev.mellanox.co.il
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jan-Bernd Themann <THEMANN@de.ibm.com>,
	OpenFabrics General <general@lists.openfabrics.org>,
	netdev@vger.kernel.org, Roland Dreier <rdreier@cisco.com>,
	Vladimir Sokolovsky <vlad@mellanox.co.il>
To: Or Gerlitz <ogerlitz@voltaire.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.188]:41220 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753916AbYFYM2k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jun 2008 08:28:40 -0400
Received: by nf-out-0910.google.com with SMTP id d3so129843nfc.21
        for <netdev@vger.kernel.org>; Wed, 25 Jun 2008 05:28:38 -0700 (PDT)
In-Reply-To: <4862304D.2050306@voltaire.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Wed, 2008-06-25 at 14:47 +0300, Or Gerlitz wrote:
> Jan-Bernd Themann wrote:
> > no, what I meant is that it is only not needed at that particular 
> > place as  the packet is not handled by LRO. Without this line the 
> > driver can set an individual  value for each SKB that is not 
> > aggregated if wished. For example when the packet is not a valid IP 
> > packet.  However, removing all ip_summed fields impacts the fragment 
> > lro mode. There we have to set some value for not aggregated packets. 
> > The SKBs are generated within the LRO engine. If desired (and if there 
> > is HW that wants to use that) we can pass that value for each provided 
> > fragment. This would add one additional paramter to the already 8 
> > parameters of __lro_proc_segment. That is of course possible.
> OK, understood, both points. 
> 
> Eli, lets add to this patch a comment in inet_lro.h saying that the 
> value of lro_mgr->ip_summed is ignored by the core lro code for drivers 
> that use the non fragmented mode.
We already have this comment:

struct net_lro_mgr {
	...
	u32 ip_summed;      /* Set in non generated SKBs in page mode */

I think we should use have it something like that:
	...
	/*
	 * Set for generated SKBs in that are not added to
	 * the frag list in fragmented mode
	 */
	u32 ip_summed;

What do you think?


>  Also for the ipoib patch, lets not set 
> this value.
Agree.



