From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] mlx4: optimize xmit path
Date: Sun, 28 Sep 2014 19:22:11 -0700
Message-ID: <1411957331.15768.91.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAMEtUuxwQ8k1wcT8U0VncnVoN=vZjU3zxswgjYPcQTLPw2pRwA@mail.gmail.com>
	 <1411930364.15768.80.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAMEtUuw861ZM+jvtFnJtwTS9krUFy09Z+rj-9LJ3UYRzOEd9zA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Or Gerlitz <gerlitz.or@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Eric Dumazet <edumazet@google.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <or.gerlitz@gmail.com>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:41550 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753532AbaI2CWO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Sep 2014 22:22:14 -0400
Received: by mail-pa0-f44.google.com with SMTP id et14so1747383pad.31
        for <netdev@vger.kernel.org>; Sun, 28 Sep 2014 19:22:13 -0700 (PDT)
In-Reply-To: <CAMEtUuw861ZM+jvtFnJtwTS9krUFy09Z+rj-9LJ3UYRzOEd9zA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2014-09-28 at 13:49 -0700, Alexei Starovoitov wrote:

> I see. So xmit_more=true overrides blueflame=on settings.

Yes, unless Mellanox folks have another way.

> I wonder what is the performance difference bf=on vs bf=off,
> also whether a burst of N packets via bf is slower than
> burst via queue+doorbell.
> Some fun exploration for driver experts :)

Prior situation : bf=on : ~4.5 Mpps

queue + doorbell every 8 packets : ~8 Mpps, up to 10Mpps if tuned
properly.

Rewritten mlx4 tx path and no burst (bf=on doorbell at every packet) :
5.3 Mpps

With the full mlx4 patch and burst = 8 -> 14.9 Mpps

This is on a 40Gb NIC, with 108 bytes packets.

(Using <= 104 bytes packets actually gives lower pps because of
'inlining' done by the driver :  8 Mpps for PKTSIZE=40 )

# cat /sys/module/mlx4_en/parameters/inline_thold
104
