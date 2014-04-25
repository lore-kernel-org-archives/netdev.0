From: =?UTF-8?B?U3Zlbm5pbmcgU8O4cmVuc2Vu?= <sss@secomea.com>
Subject: Re: [PATCH] net: guard against coalescing packets from buggy network
 drivers
Date: Fri, 25 Apr 2014 21:32:27 +0200
Message-ID: <535AB84B.20207@secomea.com>
References: <535A78ED.3020309@secomea.com>	 <1398440595.29914.77.camel@edumazet-glaptop2.roam.corp.google.com>	 <535A86F3.5010602@secomea.com> <1398444575.29914.93.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1398444575.29914.93.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On 25-04-2014 18:49, Eric Dumazet wrote:
> On Fri, 2014-04-25 at 18:01 +0200, Svenning S=C3=B8rensen wrote:
>
>> You are right, of course, there are more effective ways to catch bug=
gy
>> drivers.
>> But they will probably also be much more expensive.
>> This one is very cheap, being in a relatively cold path, especially
>> compared to the memcpy in the same path.
> It seems you missed the recent tipc thread then.
Yes, I'm not subscribed to the mailing list at the moment - too much=20
traffic and too little time..

>
> They are many ways this code path can be abused, your patch only take=
s
> care of one case.
>
> In tipc case, they added skb to shinfo->frag_list without changing
> skb->data_len.
>
> So skb_tailroom(to) was not returning 0 as it should.
>
> The invariant should be more strict.
>
> BUG_ON(to->data + to->len !=3D skb_tail_pointer(to));
>
> I still think a BUG() to catch this is better.
>
> There is no guarantee the developer/user will catch a WARN(),
> the bug could sit there a long time.
>
> I have no pity for serious bugs like that.
Neither do I.
Either BUG or WARN would have worked for me and would have saved me a=20
lot of time in chasing this bug in a monster size (almost 800 files!)=20
third party driver for this unfamiliar chip on newly developed embedded=
=20
hardware (so I couldn't be sure it wasn't a hardware bug) with nothing=20
else than a serial port and a few MB flash to store log files on.


>
> Since you spot buggy drivers, please provide their fixes or at least
> name them so that we can take care of them.
>
> Thanks
>
>
Strange, I was almost certain that I saw at least one with the same bug=
,=20
but I can't seem to find it any longer.
Maybe I looked too quick, or maybe it's been fixed by the git pull I've=
=20
made in the meantime.
I'll take a closer look if I get some spare time some day..
