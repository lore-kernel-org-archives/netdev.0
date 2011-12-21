From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/3] netlink: use vzalloc()
Date: Wed, 21 Dec 2011 23:12:31 +0100
Message-ID: <1324505551.2621.11.camel@edumazet-laptop>
References: <20111221134833.76af35e6@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:47361 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752277Ab1LUWMg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2011 17:12:36 -0500
Received: by wgbdr13 with SMTP id dr13so14916645wgb.1
        for <netdev@vger.kernel.org>; Wed, 21 Dec 2011 14:12:35 -0800 (PST)
In-Reply-To: <20111221134833.76af35e6@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 21 d=C3=A9cembre 2011 =C3=A0 13:48 -0800, Stephen Hemminger=
 a =C3=A9crit :
> The netlink pid hash can be allocated using vzalloc() rather than dir=
ect
> access to get_free_pages. It is also safe for nl_pid_hash_zalloc to u=
se
> GFP_KERNEL since it is only called from netlink_proto_init and
> nl_pid_hash_rehash. The former is already allocating table with GFP_K=
ERNEL,
> and the latter is called from netlink_insert() which already could=20
> sleep in netlink_table_grab()
>=20


But netlink_table_grab() returns with write_lock_irq(&nl_table_lock);

So we are not allowed to sleep in a
netlink_table_grab()/netlink_table_ungrab() section .
