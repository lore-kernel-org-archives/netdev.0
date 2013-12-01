From: Ding Tianhong <dthxman@gmail.com>
Subject: Re: [PATCH net] net: neighbour: make sure the handler has finished
 before kfree neighbour
Date: Sun, 01 Dec 2013 10:43:10 +0800
Message-ID: <529AA23E.8040306@gmail.com>
References: <52973704.1030202@huawei.com> <20131130.162733.145727596946626316.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: dingtianhong@huawei.com, gaofeng@cn.fujitsu.com,
	yoshfuji@linux-ipv6.org, joe@perches.com, vfalico@redhat.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f48.google.com ([209.85.160.48]:53831 "EHLO
	mail-pb0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751412Ab3LACyT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Nov 2013 21:54:19 -0500
Received: by mail-pb0-f48.google.com with SMTP id md12so16416530pbc.7
        for <netdev@vger.kernel.org>; Sat, 30 Nov 2013 18:54:18 -0800 (PST)
In-Reply-To: <20131130.162733.145727596946626316.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2013/12/1 5:27, David Miller =E5=86=99=E9=81=93:
> From: Ding Tianhong <dingtianhong@huawei.com>
> Date: Thu, 28 Nov 2013 20:28:52 +0800
>=20
>> I have met the oops in Suse11 SP2, the kernel is 2.6.32.59-0.7-defau=
lt:
>=20
> This doesn't make any sense.
>=20
> If this actually was the reason, then del_timer() would have returned=
 true,
> and thus neigh_del_timer() would have returned "1" and you would have
> seen the "Impossible event" log message that neigh_destroy() prints o=
ut.
>=20
> You may think the cause is a pending timer, but the data you've provi=
ded
> does not support this at all.
>=20
> And if it isn't happening, your patch removing that warning is wrong.
>=20
> Furthermore, if this change to use del_timer_sync() is correct, it
> probably belongs in neigh_del_timer() because all of it's other calle=
rs
> expect the timer to not be running and that all references to the obj=
ect
> are stable after such calls.
>=20
> I'm not applying this, you really need to pursue this bug fix more
> cleanly and more thoroughly because it's a non-trivial issue.
>=20
> Thanks.

ok=EF=BC=8Cthanks for the advice, I would like to think it over and mak=
e it better.

Regards
Ding

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20
