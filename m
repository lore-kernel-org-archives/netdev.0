From: Christoph Schulz <develop@kristov.de>
Subject: Re: [PATCH net] ppp: fix pppoe_dev deletion condition in
 pppoe_release()
Date: Fri, 20 Nov 2015 19:58:18 +0100
Message-ID: <20151120195818.534169fzfht9eu6i@localhost>
References: <6a9ae28f4128939528dcf64795f1de88b39a6118.1445525554.git.g.nault@alphalink.fr>
 <20151023.033048.1984003889137051787.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8;
 DelSp="Yes";
 format="flowed"
Content-Transfer-Encoding: 7bit
Cc: g.nault@alphalink.fr, netdev@vger.kernel.org, paulus@samba.org,
	nuclearcat@nuclearcat.com, Matt.Bennett@alliedtelesis.co.nz
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from server1137-han.de-nserver.de ([77.75.249.171]:45088 "EHLO
	server1137-han.de-nserver.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751654AbbKTTDr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Nov 2015 14:03:47 -0500
In-Reply-To: <20151023.033048.1984003889137051787.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

David Miller schrieb am Fri, 23 Oct 2015 03:30:48 -0700 (PDT):

> From: Guillaume Nault <g.nault@alphalink.fr>
> Date: Thu, 22 Oct 2015 16:57:10 +0200
>
>> We can't rely on PPPOX_ZOMBIE to decide whether to clear po->pppoe_dev.
>> PPPOX_ZOMBIE can be set by pppoe_disc_rcv() even when po->pppoe_dev is
>> NULL. So we have no guarantee that (sk->sk_state & PPPOX_ZOMBIE) implies
>> (po->pppoe_dev != NULL).
>> Since we're releasing a PPPoE socket, we want to release the pppoe_dev
>> if it exists and reset sk_state to PPPOX_DEAD, no matter the previous
>> value of sk_state. So we can just check for po->pppoe_dev and avoid any
>> assumption on sk->sk_state.
>>
>> Fixes: 2b018d57ff18 ("pppoe: drop PPPOX_ZOMBIEs in pppoe_release")
>> Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>
>
> Applied and queued up for -stable, thanks.

Somehow this commit (1acea4f6ce1b1c0941438aca75dd2e5c6b09db60) did not  
make it into Linux 4.2.6, 4.1.13, or 3.18.24. But I don't find it in  
your stable bundle on Patchwork either. Has this patch been  
inadvertently "lost in translation"?


Best regards,
-- 
Christoph Schulz
