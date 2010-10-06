From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next PATCH] igb: update adapter stats when reading /proc/net/dev.
Date: Tue, 5 Oct 2010 22:47:22 -0700
Message-ID: <AANLkTimTZJo2hOVCHhSpdeeCC06dOk_QXi9a24cpTFuu@mail.gmail.com>
References: <20101005141833.20929.10943.stgit@localhost>
	<1286289703.2796.292.camel@edumazet-laptop>
	<1286290393.7071.38.camel@firesoul.comx.local>
	<1286291947.2796.387.camel@edumazet-laptop>
	<1286312479.2593.35.camel@edumazet-laptop>
	<Pine.LNX.4.64.1010052313370.30765@ask.diku.dk>
	<AANLkTi=+rkietX9jAMy5BRVwAENf-mK15py7y+LYQ-XJ@mail.gmail.com>
	<1286335729.4861.13.camel@edumazet-laptop>
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
Received: from mail-iw0-f174.google.com ([209.85.214.174]:46856 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755367Ab0JFFrX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Oct 2010 01:47:23 -0400
Received: by iwn5 with SMTP id 5so9294537iwn.19
        for <netdev@vger.kernel.org>; Tue, 05 Oct 2010 22:47:22 -0700 (PDT)
In-Reply-To: <1286335729.4861.13.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 5, 2010 at 20:28, Eric Dumazet <eric.dumazet@gmail.com> wro=
te:
> Le mardi 05 octobre 2010 =C3=A0 15:34 -0700, Jeff Kirsher a =C3=A9cri=
t :
>> On Tue, Oct 5, 2010 at 14:16, Jesper Dangaard Brouer <hawk@diku.dk> =
wrote:
>> > On Tue, 5 Oct 2010, Eric Dumazet wrote:
>> >
>> >> Le mardi 05 octobre 2010 =C3=A0 17:19 +0200, Eric Dumazet a =C3=A9=
crit :
>> >>>
>> >>> Le mardi 05 octobre 2010 =C3=A0 16:53 +0200, Jesper Dangaard Bro=
uer a =C3=A9crit :
>> >>>
>> >>>> Its already racy, because "ethtool -S" reads out the stats imme=
diately,
>> >>>> and thus races with the timer.
>> >>>>
>> >>>> See: igb_ethtool.c
>> >>>> =C2=A0igb_get_ethtool_stats() invoke igb_update_stats(adapter);
>> >>>>
>> >>>
>> >>> You would be surprised how many bugs are waiting to be found and
>> >>> fixed ;)
>> >>
>> >> I took a look at igb stats, and it appears they also are racy on =
32bit
>> >> arches. igb uses u64 counters, with no synchronization between
>> >> producers(writers) and consumers(readers).
>> >
>> > Are you saying, that we need more than a simple mutex in igb_updat=
e_stats()?
>> >
>> >
>> >> Some fixes are needed ;)
>> >
>> > The question is then if Intel wants to fix it, or let it be up to =
you or me?
>> >
>>
>> I will make sure that Carolyn and Alex know about the issue. =C2=A0B=
ut,
>> feel free to submit a patch if you guys have the time.
>>
>
> I woke up early this morning, I'll provide patches to fix issues for
> net-next-2.6
>
> I'll let Intel guys doing the backporting work, but for old kernels,
> you'll probably need to use "unsigned long" instead of "u64"
>
> My plan is :
>
> - Provide 64bit counters even on 32bit arch
> - with proper synchro (include/linux/u64_stats_sync.h)
> - Add a spinlock so we can apply Jesper patch.
>
>

Thanks Eric, I really appreciate it.

--=20
Cheers,
Jeff
