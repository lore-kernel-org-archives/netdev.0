From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH][SCTP] Re: lockdep: inconsistent lock state ipv6_add_addr/sctp_v6_copy_addrlist (2.6.21-rc1)
Date: Thu, 08 Mar 2007 22:00:23 +1100
Message-ID: <E1HPGMB-0002AG-00@gondolin.me.apana.org.au>
References: <20070308074751.GA2085@ff.dom.local>
Cc: simon@arlott.org, linux-kernel@vger.kernel.org, sri@us.ibm.com,
	netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
To: jarkao2@o2.pl (Jarek Poplawski)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1416 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751060AbXCHLC1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Mar 2007 06:02:27 -0500
In-Reply-To: <20070308074751.GA2085@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jarek Poplawski <jarkao2@o2.pl> wrote:
> On 25-02-2007 10:08, Simon Arlott wrote:
>> This happens on every boot if more information is needed:
>> 
>> [   37.393715] =================================
>> [   37.393830] [ INFO: inconsistent lock state ]
>> [   37.393881] 2.6.21-rc1-git #146
>> [   37.393929] ---------------------------------
>> [   37.393979] inconsistent {softirq-on-R} -> {in-softirq-W} usage.
>> [   37.394040] hotplug/1072 [HC0[0]:SC1[2]:HE1:SE0] takes:
>> [   37.394092]  (&ndev->lock){-+-?}, at: [<b04a7944>] ipv6_add_addr+0x164/0x1e0
>> [   37.394308] {softirq-on-R} state was registered at:
>> [   37.394359]   [<b013fc42>] __lock_acquire+0x622/0xbb0
>> [   37.394515]   [<b0140652>] lock_acquire+0x62/0x80
>> [   37.394678]   [<b0511c65>] _read_lock+0x35/0x50
>> [   37.394834]   [<b050e200>] sctp_v6_copy_addrlist+0x30/0xc0
> ...
> 
> [SCTP] ipv6: inconsistent lock state ipv6_add_addr/sctp_v6_copy_addrlist
> 
> lockdep found that dev->lock taken from softirq in ipv6_add_addr
> is also taken in sctp_v6_copy_addrlist with softirqs enabled, so
> lockup is possible.

Who's calling ipv6_add_addr from softirq context? That's got to be
wrong because ipv6_add_addr requires the RTNL.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
