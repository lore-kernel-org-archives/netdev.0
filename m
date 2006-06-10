From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: netif_tx_disable vs netif_stop_queue (possible races?)
Date: Sat, 10 Jun 2006 16:59:40 +0400
Message-ID: <20060610125940.GA2983@2ka.mipt.ru>
References: <E1FoYoi-0001gg-00@gondolin.me.apana.org.au> <448993C9.8040400@gentoo.org> <20060609233531.GA15756@gondor.apana.org.au> <448ABE2D.8040401@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@vger.kernel.org,
	david-b@pacbell.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:18372 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1751494AbWFJNAS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Jun 2006 09:00:18 -0400
To: Daniel Drake <dsd@gentoo.org>
Content-Disposition: inline
In-Reply-To: <448ABE2D.8040401@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jun 10, 2006 at 01:42:21PM +0100, Daniel Drake (dsd@gentoo.org) wrote:
> Herbert Xu wrote:
> >Correct.  All callers of hard_start_xmit do so under RCU or equivalent
> >locks so they must be complete by the time synchronize_net() returns.
> 
> Does this hold for other operations? Such as:
> 
> - The netdev->set_mac_address function
> - The wireless ioctl's (SIOCSIWESSID, etc)
> 
> Are these also guaranteed to have returned after synchronize_net()?

None of above calls is protected with RCU (except set_mac_address()
called through ioctl, which is performed under read_lock which disables
preemtption), so they still can run after synchronize_net().

But if you are talking about synchronize_net() inside
unregister_netdevice(), which is called from 
usbnet_disconnect()->unregister_netdev(), than it is safe.

> Thanks,
> Daniel

-- 
	Evgeniy Polyakov
