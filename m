From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH ipsec] xfrm: prevent ipcomp scratch buffer race condition
Date: Tue, 15 Oct 2013 11:46:03 +0200
Message-ID: <20131015094603.GX7660@secunet.com>
References: <20131014160334.BCCDDE8A31@unicorn.suse.cz>
 <20131015083348.GW7660@secunet.com>
 <525D03D8.7060802@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Michal Kubecek <mkubecek@suse.cz>,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Fan Du <fan.du@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:37684 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758190Ab3JOJqG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Oct 2013 05:46:06 -0400
Content-Disposition: inline
In-Reply-To: <525D03D8.7060802@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 15, 2013 at 04:59:04PM +0800, Fan Du wrote:
>=20
>=20
> On 2013=E5=B9=B410=E6=9C=8815=E6=97=A5 16:33, Steffen Klassert wrote:
> >
> >Maybe we could disable the BHs before we fetch the percpu pointers.
> >Then we can use smp_processor_id() to get the cpu. With that we
> >could get rid of a (now useless) preempt_disable()/preempt_enable()
> >pair. Same could be done in ipcomp_compress().
>=20
> Is it possible that two tasks race scratch buffer when both of them t=
rying to compress data
> without preempt disabled? for example, when task A working on compres=
sion, then task B
> with higher priority preempts task A, and try to touch scratch buffer=
, which leaves stale
> data for task A after then.
>=20
> I think we needs preempt disabled for such case, otherwise I overlook=
 codes in somewhere else.
>=20

You overlook that preemption is disabled if the BHs are disabled.
