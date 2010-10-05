From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next PATCH] igb: update adapter stats when reading /proc/net/dev.
Date: Tue, 5 Oct 2010 15:34:36 -0700
Message-ID: <AANLkTi=+rkietX9jAMy5BRVwAENf-mK15py7y+LYQ-XJ@mail.gmail.com>
References: <20101005141833.20929.10943.stgit@localhost>
	<1286289703.2796.292.camel@edumazet-laptop>
	<1286290393.7071.38.camel@firesoul.comx.local>
	<1286291947.2796.387.camel@edumazet-laptop>
	<1286312479.2593.35.camel@edumazet-laptop>
	<Pine.LNX.4.64.1010052313370.30765@ask.diku.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jesper Dangaard Brouer <hawk@comx.dk>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>
To: Jesper Dangaard Brouer <hawk@diku.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:36514 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754234Ab0JEWei convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Oct 2010 18:34:38 -0400
Received: by iwn5 with SMTP id 5so8869249iwn.19
        for <netdev@vger.kernel.org>; Tue, 05 Oct 2010 15:34:37 -0700 (PDT)
In-Reply-To: <Pine.LNX.4.64.1010052313370.30765@ask.diku.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 5, 2010 at 14:16, Jesper Dangaard Brouer <hawk@diku.dk> wro=
te:
> On Tue, 5 Oct 2010, Eric Dumazet wrote:
>
>> Le mardi 05 octobre 2010 =C3=A0 17:19 +0200, Eric Dumazet a =C3=A9cr=
it :
>>>
>>> Le mardi 05 octobre 2010 =C3=A0 16:53 +0200, Jesper Dangaard Brouer=
 a =C3=A9crit :
>>>
>>>> Its already racy, because "ethtool -S" reads out the stats immedia=
tely,
>>>> and thus races with the timer.
>>>>
>>>> See: igb_ethtool.c
>>>> =C2=A0igb_get_ethtool_stats() invoke igb_update_stats(adapter);
>>>>
>>>
>>> You would be surprised how many bugs are waiting to be found and
>>> fixed ;)
>>
>> I took a look at igb stats, and it appears they also are racy on 32b=
it
>> arches. igb uses u64 counters, with no synchronization between
>> producers(writers) and consumers(readers).
>
> Are you saying, that we need more than a simple mutex in igb_update_s=
tats()?
>
>
>> Some fixes are needed ;)
>
> The question is then if Intel wants to fix it, or let it be up to you=
 or me?
>

I will make sure that Carolyn and Alex know about the issue.  But,
feel free to submit a patch if you guys have the time.

--=20
Cheers,
Jeff
