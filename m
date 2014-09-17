From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next] net: fix sparse warnings in SNMP_UPD_PO_STATS(_BH)
Date: Thu, 18 Sep 2014 00:43:36 +0200
Message-ID: <1410993816.2153133.168778445.4B4FD1B4@webmail.messagingengine.com>
References: <20140917212312.GA13866@kria>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Sabrina Dubroca <sd@queasysnail.net>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:55712 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756521AbaIQWnh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Sep 2014 18:43:37 -0400
Received: from compute2.internal (compute2.nyi.internal [10.202.2.42])
	by gateway2.nyi.internal (Postfix) with ESMTP id 6362520BB3
	for <netdev@vger.kernel.org>; Wed, 17 Sep 2014 18:43:36 -0400 (EDT)
In-Reply-To: <20140917212312.GA13866@kria>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 17, 2014, at 23:23, Sabrina Dubroca wrote:
> ptr used to be a non __percpu pointer (result of a this_cpu_ptr
> assignment, 7d720c3e4f0c4 ("percpu: add __percpu sparse annotations to
> net")). Since d25398df59b56 ("net: avoid reloads in SNMP_UPD_PO_STATS"),
> that's no longer the case, SNMP_UPD_PO_STATS uses this_cpu_add and ptr
> is now __percpu.
> 
> Silence sparse warnings by preserving the original type and
> annotation, and remove the out-of-date comment.
> 
> warning: incorrect type in initializer (different address spaces)
>    expected unsigned long long *ptr
>    got unsigned long long [noderef] <asn:3>*<noident>
> warning: incorrect type in initializer (different address spaces)
>    expected void const [noderef] <asn:3>*__vpp_verify
>    got unsigned long long *<noident>
> warning: incorrect type in initializer (different address spaces)
>    expected void const [noderef] <asn:3>*__vpp_verify
>    got unsigned long long *<noident>
> 
> Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

This clears up quite a lot of warnings in ipv6/mcast.c.

Thanks,
Hannes
