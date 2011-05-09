From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] veth: use batched device unregister
Date: Mon, 09 May 2011 10:20:36 +0200
Message-ID: <1304929236.3342.8.camel@edumazet-laptop>
References: <1304793749.3207.26.camel@edumazet-laptop>
	 <1304838742.3207.45.camel@edumazet-laptop>
	 <F57561A93EFF5E88729A8D53@nimrod.local>
	 <7B76F9D75FD26D716624004B@nimrod.local>
	 <20110508125028.GK2641@linux.vnet.ibm.com>
	 <B2891EFD056565BBD4DBCE16@nimrod.local>
	 <20110508134425.GL2641@linux.vnet.ibm.com>
	 <C449131127D58077CB25C9D8@Ximines.local>
	 <20110508144749.GR2641@linux.vnet.ibm.com>
	 <AB9DE9E04289CF29CA79CC67@Ximines.local>
	 <20110508154854.GT2641@linux.vnet.ibm.com>
	 <1304888447.3207.66.camel@edumazet-laptop>
	 <1304916275.3207.79.camel@edumazet-laptop>
	 <BANLkTim2e1Gm_jqfY89is-FfRYTu2=G02w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, Alex Bligh <alex@alex.org.uk>,
	netdev@vger.kernel.org, Jesse Gross <jesse@nicira.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Ben Greear <greearb@candelatech.com>
To: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirqus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:37476 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753111Ab1EIIUk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 May 2011 04:20:40 -0400
Received: by wya21 with SMTP id 21so3680288wya.19
        for <netdev@vger.kernel.org>; Mon, 09 May 2011 01:20:39 -0700 (PDT)
In-Reply-To: <BANLkTim2e1Gm_jqfY89is-FfRYTu2=G02w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 09 mai 2011 =C3=A0 08:56 +0200, Micha=C5=82 Miros=C5=82aw a =C3=
=A9crit :

> You could change dellink callers to always pass head !=3D NULL. As a
> side effect, unregister_netdevice_queue() would do just what its name
> suggests.

Good idea. At first  glance, macvlan and rtnetlink.c would need a
change.

This would help macvlan_device_event( event=3DNETDEV_UNREGISTER) use ba=
tch
as well.

And yes, unregister_netdevice_queue(dev, head) would only make a

list_move_tail(&dev->unreg_list, head);

Will submit a patch soon, thanks !


