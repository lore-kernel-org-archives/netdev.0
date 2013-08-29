From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATCH net-next v10 10/11] vxlan: respect scope_id for ll addr
Date: Thu, 29 Aug 2013 17:20:54 -0400
Message-ID: <OF231098A1.4B9DE99C-ON85257BD6.0074456A-85257BD6.00754552@us.ibm.com>
References: <1377667379-2315-1-git-send-email-amwang@redhat.com> <1377667379-2315-11-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Cong Wang <amwang@redhat.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:60233 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751625Ab3H2VVE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Aug 2013 17:21:04 -0400
Received: from /spool/local
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <dlstevens@us.ibm.com>;
	Thu, 29 Aug 2013 15:21:04 -0600
In-Reply-To: <1377667379-2315-11-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

netdev-owner@vger.kernel.org wrote on 08/28/2013 01:22:58 AM:

> From: Cong Wang <amwang@redhat.com>
 
> As pointed out by David, we should take care of scope id for ll
> addr, and use it for route lookup.

        It is an error to have a zero scope_id for an LL addr, but
this code is not correct, because it only honors scope_id for
LL addrs. Multicast addresses also require scope_id be set.
        This shouldn't be in the transmit path. The netlink code
that sets it should require it be nonzero for LL addrs and multicast
addrs when it is set, and the transmit path should *always* use scope_id,
whether for an lladdr or not, whether scope_id is zero or not.

        I'm away this week and won't be able to review these in
detail until next week, but wanted to get that comment in.

                                                +-DLS
