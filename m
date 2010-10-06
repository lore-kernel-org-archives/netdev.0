From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next] igb: fix stats handling
Date: Tue, 5 Oct 2010 22:49:39 -0700
Message-ID: <AANLkTinbYu9cY9+=Z4MQU69mm+QsozbWsPp6YZOft_Cb@mail.gmail.com>
References: <20101005141833.20929.10943.stgit@localhost>
	<1286289703.2796.292.camel@edumazet-laptop>
	<1286290393.7071.38.camel@firesoul.comx.local>
	<1286291947.2796.387.camel@edumazet-laptop>
	<1286312479.2593.35.camel@edumazet-laptop>
	<Pine.LNX.4.64.1010052313370.30765@ask.diku.dk>
	<AANLkTi=+rkietX9jAMy5BRVwAENf-mK15py7y+LYQ-XJ@mail.gmail.com>
	<1286335729.4861.13.camel@edumazet-laptop>
	<1286339791.4861.26.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jesper Dangaard Brouer <hawk@diku.dk>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jesper Dangaard Brouer <hawk@comx.dk>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:52078 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753974Ab0JFFtk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Oct 2010 01:49:40 -0400
Received: by iwn5 with SMTP id 5so9296763iwn.19
        for <netdev@vger.kernel.org>; Tue, 05 Oct 2010 22:49:39 -0700 (PDT)
In-Reply-To: <1286339791.4861.26.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 5, 2010 at 21:36, Eric Dumazet <eric.dumazet@gmail.com> wro=
te:
> Le mercredi 06 octobre 2010 =C3=A0 05:28 +0200, Eric Dumazet a =C3=A9=
crit :
>
>> I'll let Intel guys doing the backporting work, but for old kernels,
>> you'll probably need to use "unsigned long" instead of "u64"
>>
>> My plan is :
>>
>> - Provide 64bit counters even on 32bit arch
>> - with proper synchro (include/linux/u64_stats_sync.h)
>> - Add a spinlock so we can apply Jesper patch.
>
> Here is the net-next-2.6 patch, I am currently enable to test it, the
> dev machine with IGB NIC cannot be restarted until tomorrow, my son
> Nicolas is currently using it ;)
>
> Could you and/or Jesper test it, possibly on 32 and 64 bit kernels ?
>
> Thanks !
>
> [PATCH net-next] igb: fix stats handling
>
> There are currently some problems with igb.
>
> - On 32bit arches, maintaining 64bit counters without proper
> synchronization between writers and readers.
>
> - Stats updated every two seconds, as reported by Jesper.
> =C2=A0 (Jesper provided a patch for this)
>
> - Potential problem between worker thread and ethtool -S
>
> This patch uses u64_stats_sync, and convert everything to be 64bit sa=
fe,
> SMP safe, even on 32bit arches.
>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
> =C2=A0drivers/net/igb/igb.h =C2=A0 =C2=A0 =C2=A0 =C2=A0 | =C2=A0 =C2=A0=
7 +-
> =C2=A0drivers/net/igb/igb_ethtool.c | =C2=A0 10 +-
> =C2=A0drivers/net/igb/igb_main.c =C2=A0 =C2=A0| =C2=A0111 +++++++++++=
++++++++++++---------
> =C2=A03 files changed, 94 insertions(+), 34 deletions(-)
>

Thanks again Eric!  I will add your patch to my queue.

--=20
Cheers,
Jeff
