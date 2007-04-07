From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] net: Add etun driver
Date: Fri, 06 Apr 2007 20:08:22 -0600
Message-ID: <m1tzvt3pih.fsf@ebiederm.dsl.xmission.com>
References: <m1abxl5j4s.fsf@ebiederm.dsl.xmission.com>
	<adak5wp6x1m.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Ben Greear <greearb@candelatech.com>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	Dmitry Mishin <dim@openvz.org>,
	Linux Containers <containers@lists.osdl.org>
To: Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:53190 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965095AbXDGCJk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Apr 2007 22:09:40 -0400
In-Reply-To: <adak5wp6x1m.fsf@cisco.com> (Roland Dreier's message of "Fri, 06
	Apr 2007 13:57:25 -0700")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Roland Dreier <rdreier@cisco.com> writes:

>  > +/*
>  > + * The higher levels take care of making this non-reentrant (it's
>  > + * called with bh's disabled).
>  > + */
>  > +static int etun_xmit(struct sk_buff *skb, struct net_device *tx_dev)
>
> You have this comment, but then...
>
>  > +	dev->features		= NETIF_F_FRAGLIST
>  > +				  | NETIF_F_HIGHDMA
>  > +				  | NETIF_F_LLTX;
>
> you set LLTX, which means that the upper layers _don't_ make sure that
> your xmit routine is not reentrant.
>
> It looks like the impact of multiple simultaneous xmit calls is just
> the possibility of screwing up the statistics, but still I think you
> want to drop the LLTX feature (since you have no lock of your own to
> try and take).

Yup.  That is an inconsistency and probably a bug.  I have to think
through what makes most sense in this case.  Though the cheap answer
is clearly to remove NETIF_F_LLTX.


