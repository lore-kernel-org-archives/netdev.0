From: Daniel Drake <dsd@gentoo.org>
Subject: Re: netif_tx_disable vs netif_stop_queue (possible races?)
Date: Sat, 10 Jun 2006 13:42:21 +0100
Message-ID: <448ABE2D.8040401@gentoo.org>
References: <E1FoYoi-0001gg-00@gondolin.me.apana.org.au> <448993C9.8040400@gentoo.org> <20060609233531.GA15756@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, david-b@pacbell.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta07-winn.ispmail.ntl.com ([81.103.221.47]:54909 "EHLO
	mtaout01-winn.ispmail.ntl.com") by vger.kernel.org with ESMTP
	id S1751508AbWFJMlE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 10 Jun 2006 08:41:04 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20060609233531.GA15756@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> Correct.  All callers of hard_start_xmit do so under RCU or equivalent
> locks so they must be complete by the time synchronize_net() returns.

Does this hold for other operations? Such as:

- The netdev->set_mac_address function
- The wireless ioctl's (SIOCSIWESSID, etc)

Are these also guaranteed to have returned after synchronize_net()?

Thanks,
Daniel
