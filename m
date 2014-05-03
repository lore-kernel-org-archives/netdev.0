From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: Re: [PATCH net,stable] net: cdc_mbim: __vlan_find_dev_deep need rcu_read_lock
Date: Sat, 03 May 2014 11:16:50 +0200
Message-ID: <87ppjv8bnh.fsf@nemi.mork.no>
References: <1399066111-22803-1-git-send-email-bjorn@mork.no>
	<1399067861.2140.6.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Greg Suarez <gsuarez-AKjrjAf1O7qe8kRwQpwjMg@public.gmane.org>,
	Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
To: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1399067861.2140.6.camel-XN9IlZ5yJG9HTL0Zs8A6p/gx64E7kk8eUsxypvmhUTTZJqsBc5GL+g@public.gmane.org>
	(Eric Dumazet's message of "Fri, 02 May 2014 14:57:41 -0700")
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:

> While this 'removes' the warning, this doesn't solve the fundamental
> problem.
>
> If you write :
>
> rcu_read_lock();
> netdev =3D __vlan_find_dev_deep(...)
> rcu_read_unlock();
>
> Then you cannot dereference netdev safely after the unlock.
>
> In order to do so, you need to take a reference on netdev (aka
> dev_hold()) before doing rcu_read_unlock();
>
> And of course, release it later (aka dev_put()) when you are done wit=
h
> netdev.

Doh! Now that you tell me, this is pretty obvious.  Thanks.  Will fix
and resubmit.


Bj=C3=B8rn
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
