From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: tun issue after e0b46d0ee9c: tun: Use iovec iterators
Date: Fri, 28 Nov 2014 22:35:03 +0000
Message-ID: <20141128223503.GE29748@ZenIV.linux.org.uk>
References: <5478CC27.9040705@redhat.com>
 <20141128203733.GD29748@ZenIV.linux.org.uk>
 <5478F2BB.9050409@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, netdev <netdev@vger.kernel.org>
To: Marcelo Ricardo Leitner <mleitner@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:55882 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751209AbaK1WfH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Nov 2014 17:35:07 -0500
Content-Disposition: inline
In-Reply-To: <5478F2BB.9050409@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 28, 2014 at 08:10:03PM -0200, Marcelo Ricardo Leitner wrote:
> >Could you print vnet_hdr_sz and sizeof(gso) right after that
> >copy_from_iter(&gso, ...)?
> 
> Did a:
>         else {
>                 err = skb_copy_datagram_from_iter(skb, 0, from, len);
> +               pr_err("vnet_hdr_sz=%d sizeof(gso)=%lu\n",
> tun->vnet_hdr_sz, sizeof(gso));
>                 if (!err && msg_control) {
> 
> Got, for tun:
> [   50.514165] tun: vnet_hdr_sz=12 sizeof(gso)=10
> 
> for tap:
> [   82.911840] tun: vnet_hdr_sz=10 sizeof(gso)=10
> 
> other values were just as before.

Hmm...  Do you have
commit 8c847d254146d32c86574a1b16923ff91bb784dd
Author: Jason Wang <jasowang@redhat.com>
Date:   Thu Nov 13 16:54:14 2014 +0800

    tun: fix issues of iovec iterators using in tun_put_user()
in your tree?
