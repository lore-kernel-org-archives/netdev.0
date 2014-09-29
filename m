From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next] mlx4: optimize xmit path
Date: Sun, 28 Sep 2014 22:08:43 -0700
Message-ID: <CAMEtUuzhioRKYUTkKVByO_3BJ41Zj_ehrE0yxZPbTExfv5h83g@mail.gmail.com>
References: <CAMEtUuxwQ8k1wcT8U0VncnVoN=vZjU3zxswgjYPcQTLPw2pRwA@mail.gmail.com>
	<1411930364.15768.80.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAMEtUuw861ZM+jvtFnJtwTS9krUFy09Z+rj-9LJ3UYRzOEd9zA@mail.gmail.com>
	<1411957331.15768.91.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Or Gerlitz <gerlitz.or@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Eric Dumazet <edumazet@google.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <or.gerlitz@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f43.google.com ([209.85.215.43]:50010 "EHLO
	mail-la0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750753AbaI2FIp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2014 01:08:45 -0400
Received: by mail-la0-f43.google.com with SMTP id gb8so7711706lab.16
        for <netdev@vger.kernel.org>; Sun, 28 Sep 2014 22:08:43 -0700 (PDT)
In-Reply-To: <1411957331.15768.91.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Sep 28, 2014 at 7:22 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Sun, 2014-09-28 at 13:49 -0700, Alexei Starovoitov wrote:
>
>> I see. So xmit_more=true overrides blueflame=on settings.
>
> Yes, unless Mellanox folks have another way.
>
>> I wonder what is the performance difference bf=on vs bf=off,
>> also whether a burst of N packets via bf is slower than
>> burst via queue+doorbell.
>> Some fun exploration for driver experts :)
>
> Prior situation : bf=on : ~4.5 Mpps
>
> queue + doorbell every 8 packets : ~8 Mpps, up to 10Mpps if tuned
> properly.
>
> Rewritten mlx4 tx path and no burst (bf=on doorbell at every packet) :
> 5.3 Mpps
>
> With the full mlx4 patch and burst = 8 -> 14.9 Mpps
>
> This is on a 40Gb NIC, with 108 bytes packets.
>
> (Using <= 104 bytes packets actually gives lower pps because of
> 'inlining' done by the driver :  8 Mpps for PKTSIZE=40 )
>
> # cat /sys/module/mlx4_en/parameters/inline_thold
> 104

nice. Understood. All makes sense.
I'm not sure whether it's worth to break it down
into small pieces. Imo it's good to go as-is.
'inlining' tuning can come later.
Thanks again!
