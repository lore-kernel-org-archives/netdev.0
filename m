From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: NBMA GRE over IPsec behind NAT
Date: Wed, 21 Jan 2009 11:14:04 +0200
Message-ID: <4976E75C.8070804@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org, Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f20.google.com ([209.85.219.20]:46841 "EHLO
	mail-ew0-f20.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753242AbZAUJOJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jan 2009 04:14:09 -0500
Received: by ewy13 with SMTP id 13so1363423ewy.13
        for <netdev@vger.kernel.org>; Wed, 21 Jan 2009 01:14:07 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I sent a mail earlier about this subject, see:
http://marc.info/?l=linux-netdev&m=122232910618099&w=4

I've been thinking more about this and reading the code
trying to figure out how to fix this.

One idea for the fix would be:
1. Include the NAT Original Address in NDA_LLADDR (this way
   we don't have to modify struct neighbour)
2. Add new Neighbor Cache Entry Flag (NTF_NATOA?) to specify
   if the NAT-OA is present
3. Modify neighbor cache to cope with the new flag and address
4. Add NAT-OA field for ipv4 in struct flowi
5. ipv4/xfrm4_policy.c: __xfrm4_find_bundle() to compare NAT-OA
   if it is specified in struct flowi.
6. Possibly ipv4/xfrm4_policy.c: _decode_session4() would
   extract the NAT-OA to struct flowi from skb->dst->neighbour.

Does this sound something that might work? Would it be an
acceptable approach?

- Timo
