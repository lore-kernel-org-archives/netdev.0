From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: Re: [PATCH 6/23] [PATCH] [XFRM] STATE: Search by address using source
 address list.
Date: Wed, 02 Aug 2006 11:04:36 +0900
Message-ID: <44D00834.1010005@linux-ipv6.org>
References: <11541654182334-git-send-email-nakam@linux-ipv6.org> <20060801.170618.75430766.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [203.178.140.9] ([203.178.140.9]:59793 "EHLO mail.gomagoma.org")
	by vger.kernel.org with ESMTP id S1751015AbWHBCEj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2006 22:04:39 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060801.170618.75430766.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Masahide NAKAMURA <nakam@linux-ipv6.org>
> Date: Sat, 29 Jul 2006 18:30:18 +0900
> 
>> +#ifdef CONFIG_XFRM_ADVANCED
>> +	struct xfrm_state	*(*state_lookup_byaddr)(xfrm_address_t *daddr, xfrm_address_t *saddr, u8 proto);
>> +#endif
> 
> I think we should delete XFRM_ADVANCED config option, it is only
> serving to make the code very ugly and full of ifdefs.

I see, I remove it.

My thought was to keep XFRM code intact as possible for users who wants only IPsec.
But don't worry, it should not be changed existing logic of course then I've made
regression test for IPsec behavior with both case: new config is off and on.
Then I guess I can remove the config easily.


>> +#ifdef CONFIG_XFRM_ADVANCED
>> +	int use_spi = xfrm_id_proto_match(x->id.proto, IPSEC_PROTO_ANY);
>> +#else
>> +	int use_spi = 1;
>> +#endif
> 
> Why this transformation?  In fact, you added several others.
> xfrm_id_proto_match() with userproto argument IPSEC_PROTO_ANY
> always evaluates to one.
> 
> If you intend to change the userproto argument in some future
> changeset, then add the xfrm_id_proto_match() call in that
> changeset.

You already find out by another mail, but I should have to change
patch order to get it easily for others or write more particular commit log.

Thanks,

-- 
Masahide NAKAMURA
