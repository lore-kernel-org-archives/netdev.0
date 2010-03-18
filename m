From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] tcp: Generalized TTL Security Mechanism
Date: Thu, 18 Mar 2010 10:59:39 -0700
Message-ID: <20100318105939.57f8d377@nehalam>
References: <20100110220034.4d46ba8a@nehalam>
	<alpine.LRH.2.00.1003180833420.24946@netcore.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Pekka Savola <pekkas@netcore.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:57868 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754017Ab0CRR7m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Mar 2010 13:59:42 -0400
In-Reply-To: <alpine.LRH.2.00.1003180833420.24946@netcore.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 18 Mar 2010 08:36:48 +0200 (EET)
Pekka Savola <pekkas@netcore.fi> wrote:

> Hi,
> 
> On Sun, 10 Jan 2010, Stephen Hemminger wrote:
> > This patch adds the kernel portions needed to implement
> > RFC 5082 Generalized TTL Security Mechanism (GTSM).
> > It is a lightweight security measure against forged
> > packets causing DoS attacks (for BGP).
> ...
> 
> It's nice to see this added.  However, I must add that a compliant RFC 
> 5082 implementation is required to have similar TTL treatment for ICMP 
> errors which relate to the protected session.  AFAIK this does not 
> support that.
> 
> The experimental, earlier spec (GTSH, RFC3682) did not have this 
> requirement.  Most if not all implementations support only GTSH mode. 
> So a backward-compatibility option may be desirable.

The ICMP receive error handling does need to be updated. 

But any application using GTSM should be setting IP_TTL socket option
to set send TTL. But, not sure if Linux TCP ever sends ICMP 
for existing sessions at all.
