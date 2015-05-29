From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Fw: [Bug 99091] New: Kernel panic while sending network packets
 over TAP interface
Date: Fri, 29 May 2015 11:01:44 +0800
Message-ID: <20150529030143.GA16290@gondor.apana.org.au>
References: <20150528073556.335fd7a3@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:35077 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753342AbbE2DBs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 May 2015 23:01:48 -0400
Content-Disposition: inline
In-Reply-To: <20150528073556.335fd7a3@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger <stephen@networkplumber.org> wrote:
>
> Our setup is designed specifically to cause the calling path "bridge transmit"
> - "VLAN transmit" - "bridge transmit" - "GRE or TAP transmit" as reflected by
> the crash dump. It appears that this sequence hits a race condition or a
> corrupted/uninitialized error queue in skb_queue_tail().

Your bug is simple.  Somebody is setting skb->sk when they shouldn't.
Presumably it's whatever that injected the packet into your stack,
i.e., your NIC driver.  So you should start looking for blame there.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
