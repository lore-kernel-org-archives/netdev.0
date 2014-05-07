From: V JobNickname <workofv@gmail.com>
Subject: Re: Is 3.18 patch "The tcp: TSO packets automatic sizing" will cause
 to Troughput drop when enable NO_HZ_IDEL or HIGH_RES_TIMERS ?
Date: Wed, 7 May 2014 23:51:29 +0800
Message-ID: <CANHbGWsqBZEw0-6A0zE6PrSUF1osbN86mcYxjo9Z4V6WWyXTww@mail.gmail.com>
References: <CANHbGWs=oQBDVVZc8h5wX0WY+PRbQfCqiv5FrF1tH29QGiRndA@mail.gmail.com>
	<CADVnQy=1WdUT1xHX04uBQtROwOYDZF6idw1Qx2o2DM13kWWjFQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f178.google.com ([209.85.223.178]:54985 "EHLO
	mail-ie0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755603AbaEGPva (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2014 11:51:30 -0400
Received: by mail-ie0-f178.google.com with SMTP id lx4so1151145iec.23
        for <netdev@vger.kernel.org>; Wed, 07 May 2014 08:51:30 -0700 (PDT)
In-Reply-To: <CADVnQy=1WdUT1xHX04uBQtROwOYDZF6idw1Qx2o2DM13kWWjFQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-05-07 0:48 GMT+08:00 Neal Cardwell <ncardwell@google.com>:
> On Tue, May 6, 2014 at 12:17 PM, V JobNickname <workofv@gmail.com> wrote:
>> More detail trace, the first commit of 3.10.18, tcp: TSO packets
>> automatic sizing, cause to this issue.
>> https://git.kernel.org/cgit/linux/kernel/git/stable/linux-stable.git/diff/?id=5e25ba5003ee5de0ba2be56bfd54d16d4b1b028d
>
> To provide another data point, it would be interesting to know what
> performance you see with v3.15-rc4. Linux 3.15 has the following
> patch:
>
>  740b0f1841f6  tcp: switch rtt estimations to usec resolution
>
> That patch switches tcp_update_pacing_rate() to use microsecond RTTs
> for its calculation. That may help things in your case. (As Eric says,
> more details would help.)
>
>> I don't know why this TSO patch affect my network since the network
>> driver doesn't enable NETIF_F_TSO.
>
> Keep in mind that anytime the Linux TCP code or commit descriptions
> talk about "TSO", the same applies to GSO. Is GSO enabled for your
> device?
>
> neal

Porting to the v3.15-rc4 from main stream, the performance is well when
 enabled NO_HZ_IDEL or HIGH_RES_TIMERS.

I also try the version before commit 740b0f1841f6  tcp: switch rtt
estimations to usec resolution, i.e
363ec392352 net: add skb_mstamp infrastructure,
also not cause to performance drop. So I think my case is regardless
to use jiffie or nesc in tcp_update_pacing_rate().

Then I try more eraly version and found that in 3.14-rc2 thes case was
hit but solved at 3.14-rc3.
(I use "git checkout -b 3.14-rc2 v3.14-rc2" and "git checkout -b
3.14-rc3 v3.14-rc3"  to get taged version,
and use "git checkout 3.14-rc2/3.14-rc3 to switch between". Hope my
usage are correct, since I'm not familer with git.)

I think some commit between 3.14-rc2 and 3.14-rc3 can help find the
root cause of my case.

ps.
But I don't know how to use git to update from rc2 to rc3 by each
commit(or maybe binary search commit log), and find that one commit.

For example, I would like to following logs start from 3.14-rc2 tag in
https://git.kernel.org/cgit/linux/kernel/git/stable/linux-stable.git/log/?h=linux-3.14.y&ofs=1650

Can I,

git checkout 3.14-rc2 -- switch to 3.14-rc2
git checout 07b0e5b10258b48e5edfb6c8ac156f05510eb775 (ASoC: da9055:
Fix device registration of PMIC and CODEC devices)
will the commit between this commit and 3.14-rc2 also updated?
if this commit solve my case, I can try some one commit between it and 3.14-rc2.
such as
git checkout a49f56eec54d864ba0fda838e4c8bf5c72f3eb08 (microblaze: Fix
a typo when disabling stack protection)
should I revert to 3.14-rc2 first, or the git will done it?

Thanks
