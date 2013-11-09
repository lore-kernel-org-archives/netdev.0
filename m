From: Ding Tianhong <dthxman@gmail.com>
Subject: Re: [PATCH net-next v2 2/10] bonding: rebuild the lock use for bond_mii_monitor()
Date: Sat, 09 Nov 2013 21:51:03 +0800
Message-ID: <527E3DC7.3020908@gmail.com>
References: <527C4771.90207@huawei.com> <527D0303.8030806@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ding Tianhong <dingtianhong@huawei.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Veaceslav Falico <vfalico@redhat.com>,
	Netdev <netdev@vger.kernel.org>
To: Nikolay Aleksandrov <nikolay@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f49.google.com ([209.85.160.49]:62024 "EHLO
	mail-pb0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752479Ab3KIOBv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Nov 2013 09:01:51 -0500
Received: by mail-pb0-f49.google.com with SMTP id um1so1353181pbc.8
        for <netdev@vger.kernel.org>; Sat, 09 Nov 2013 06:01:50 -0800 (PST)
In-Reply-To: <527D0303.8030806@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2013/11/8 23:28, Nikolay Aleksandrov =E5=86=99=E9=81=93:
> On 11/08/2013 03:07 AM, Ding Tianhong wrote:
> In fact the bond cannot disappear while this function is running, so =
this test
> should be able to run outside the RCU region if I'm not missing somet=
hing :-)
> It'll be just as useful as running inside the region, at most a free =
run may
> happen if there's one slave and it disappears.
>
>
> This is unnecessary, bond_has_slaves() should be enough. See bond_sta=
rt_xmit()
> and also the list_empty comment in include/linux/rculist.h for more i=
nformation why.
> My bond_has_slaves() comments apply to all the patches that use it.
>
>

yes, you are right, I make a silly mistake, the bond list itself is no=20
need to copy, it
dose not occur any problem if it be changed.

The curr_active_slave needs copy for peer, as it may be changed at=20
monitor running.

Regards.
Ding

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
