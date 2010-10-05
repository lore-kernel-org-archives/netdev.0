From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH] igb: update adapter stats when reading
 /proc/net/dev.
Date: Tue, 05 Oct 2010 16:41:43 +0200
Message-ID: <1286289703.2796.292.camel@edumazet-laptop>
References: <20101005141833.20929.10943.stgit@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: Jesper Dangaard Brouer <hawk@comx.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:48633 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751005Ab0JEOls (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Oct 2010 10:41:48 -0400
Received: by fxm4 with SMTP id 4so423017fxm.19
        for <netdev@vger.kernel.org>; Tue, 05 Oct 2010 07:41:47 -0700 (PDT)
In-Reply-To: <20101005141833.20929.10943.stgit@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 05 octobre 2010 =C3=A0 16:18 +0200, Jesper Dangaard Brouer a =C3=
=A9crit :
> Network driver igb: Improve the accuracy of stats in /proc/net/dev, b=
y
> updating the adapter stats when reading /proc/net/dev.  Currently the
> stats are updated by the watchdog timer every 2 sec, or when getting
> stats via ethtool -S.
>=20
> A number of userspace apps read these /proc/net/dev stats every secon=
d,
> e.g. ifstat, which then gives a perceived very bursty traffic pattern=
,
> which is actually false.
>=20
> Signed-off-by: Jesper Dangaard Brouer <hawk@comx.dk>

Unfortunately this is racy with igb_watchdog_task()

igb_update_stats() must be called under protection of a lock.



