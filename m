From: David Miller <davem@davemloft.net>
Subject: Re: [v2] act_mirred: Fix bogus header when redirecting from VLAN
Date: Fri, 17 Apr 2015 13:29:02 -0400 (EDT)
Message-ID: <20150417.132902.1510959002713450218.davem@davemloft.net>
References: <20150417021501.GB22835@gondor.apana.org.au>
	<20150417024029.GA6718@Alexeis-MacBook-Pro.local>
	<20150417053209.GA23855@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org,
	hadi@cyberus.ca
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45293 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932379AbbDQR3E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Apr 2015 13:29:04 -0400
In-Reply-To: <20150417053209.GA23855@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 17 Apr 2015 13:32:09 +0800

> On Thu, Apr 16, 2015 at 07:40:30PM -0700, Alexei Starovoitov wrote:
>> On Fri, Apr 17, 2015 at 10:15:01AM +0800, Herbert Xu wrote:
>> > > seems the cleaner fix will be to push skb->mac_len instead?
>> > 
>> > No skb->mac_len is the same as skb2->dev->hard_header_len.
>> 
>> hmm. please help me understand the problem then.
>> In the commit log you mentioned that your vlan dev and ifb
>> have unequal hard header length. I think that can only happen if
>> your master dev used to create vlan, didn't have vlan offload,
>> so vlandev->hhl = 18 and ifb->hhl = 14. Then when tagged packet
>> arrives on master device we call skb_vlan_untag() and
>> skb->mac_len becomes 14, then vlan_do_receive() will do
> 
> You are right.  I should've just used mac_len.
> 
> ---8<---
> When you redirect a VLAN device to any device, you end up with
> crap in af_packet on the xmit path because hard_header_len is
> not equal to skb->mac_len.  So the redirected packet contains
> four extra bytes at the start which then gets interpreted as
> part of the MAC address.
> 
> This patch fixes this by only pushing skb->mac_len.  We also
> need to fix ifb because it tries to undo the pushing done by
> act_mirred.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied.
