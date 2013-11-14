From: Felipe Contreras <felipe.contreras@gmail.com>
Subject: Re: [PATCH v2] mac80211: add assoc beacon timeout logic
Date: Thu, 14 Nov 2013 04:44:49 -0600
Message-ID: <CAMP44s1orLwg4v8UPM_1c-PspKQd5run_wAwHj-8oKmj2uqUgw@mail.gmail.com>
References: <1384119945-31213-1-git-send-email-felipe.contreras@gmail.com>
	<1384160932.14334.6.camel@jlt4.sipsolutions.net>
	<CAMP44s3TFSgWuR8gVoFBznNP+t9mz+to===9i1PAnra4ogKu9w@mail.gmail.com>
	<1384184624.14334.31.camel@jlt4.sipsolutions.net>
	<CAMP44s2cVVe4-yW214B9hJu7n6M1onZpZaPCj5N0Fi1JWDKKsw@mail.gmail.com>
	<1384188067.14334.45.camel@jlt4.sipsolutions.net>
	<CAMP44s3nkj2wZYCPve7EhyeD7sEFmpUN=-h015dOP68PcNSTug@mail.gmail.com>
	<1384189227.14334.48.camel@jlt4.sipsolutions.net>
	<CAMP44s1yJMd+9G5yu988GqafRYnAteN-y-WWDe-rJh_qQpSPkQ@mail.gmail.com>
	<1384367422.14578.20.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-wireless Mailing List <linux-wireless@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	"John W. Linville" <linville@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f42.google.com ([209.85.215.42]:44564 "EHLO
	mail-la0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753280Ab3KNKov (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Nov 2013 05:44:51 -0500
In-Reply-To: <1384367422.14578.20.camel@jlt4.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 13, 2013 at 12:30 PM, Johannes Berg
<johannes@sipsolutions.net> wrote:
> On Mon, 2013-11-11 at 12:06 -0600, Felipe Contreras wrote:
>
>> > The not receiving part is a bug. I think you're probably receiving
>> > beacons once associated though?
>>
>> Nope. Never.
>
> That's odd, firmware bug? But it's still odd since windows works?
>
>> Moreover, if continuing the association without beacons has a legal a
>> problem, that problem would exist for drivers that don't have the
>> IEEE80211_HW_NEED_DTIM_BEFORE_ASSOC flag, wouldn't it? How exactly
>> would trying to associate with need_beacon break the law, but not if
>> !need_beacon?
>
> Well, it's actually somewhat unlikely you'd break the law, although
> possible, since eventually you'd get disconnected from the AP anyway?

I get disconnected from the AP due to other bugs, you are making the
assumption that it's because of the lack of beacons.

I saw this the last time I experienced a disconnect:

Nov 13 16:29:48 nysa kernel: iwlwifi 0000:02:00.0: fail to flush all
tx fifo queues Q 2
Nov 13 16:29:48 nysa kernel: iwlwifi 0000:02:00.0: Current SW read_ptr
213 write_ptr 214
Nov 13 16:29:48 nysa kernel: iwl data: 00000000: 00 00 20 00 00 00 00
00 00 00 00 00 00 00 00 00  .. .............
Nov 13 16:29:48 nysa kernel: iwlwifi 0000:02:00.0: FH TRBs(0) = 0x8000302e
Nov 13 16:29:48 nysa kernel: iwlwifi 0000:02:00.0: FH TRBs(1) = 0x801020d5
Nov 13 16:29:48 nysa kernel: iwlwifi 0000:02:00.0: FH TRBs(2) = 0x80201016
Nov 13 16:29:48 nysa kernel: iwlwifi 0000:02:00.0: FH TRBs(3) = 0x803000fb
Nov 13 16:29:48 nysa kernel: iwlwifi 0000:02:00.0: FH TRBs(4) = 0x00000000
Nov 13 16:29:48 nysa kernel: iwlwifi 0000:02:00.0: FH TRBs(5) = 0x00000000
Nov 13 16:29:48 nysa kernel: iwlwifi 0000:02:00.0: FH TRBs(6) = 0x00000000
Nov 13 16:29:48 nysa kernel: iwlwifi 0000:02:00.0: FH TRBs(7) = 0x00709010
Nov 13 16:29:48 nysa kernel: iwlwifi 0000:02:00.0: Q 0 is active and
mapped to fifo 3 ra_tid 0x0000 [252,252]
Nov 13 16:29:48 nysa kernel: iwlwifi 0000:02:00.0: Q 1 is active and
mapped to fifo 2 ra_tid 0x0000 [23,23]
Nov 13 16:29:48 nysa kernel: iwlwifi 0000:02:00.0: Q 2 is active and
mapped to fifo 1 ra_tid 0x0000 [213,214]
Nov 13 16:29:48 nysa kernel: iwlwifi 0000:02:00.0: Q 3 is active and
mapped to fifo 0 ra_tid 0x0000 [47,47]
Nov 13 16:29:48 nysa kernel: iwlwifi 0000:02:00.0: Q 4 is active and
mapped to fifo 0 ra_tid 0x0000 [0,0]
Nov 13 16:29:48 nysa kernel: iwlwifi 0000:02:00.0: Q 5 is active and
mapped to fifo 4 ra_tid 0x0000 [0,0]
Nov 13 16:29:48 nysa kernel: iwlwifi 0000:02:00.0: Q 6 is active and
mapped to fifo 2 ra_tid 0x0000 [0,0]
Nov 13 16:29:48 nysa kernel: iwlwifi 0000:02:00.0: Q 7 is active and
mapped to fifo 5 ra_tid 0x0000 [0,0]
Nov 13 16:29:48 nysa kernel: iwlwifi 0000:02:00.0: Q 8 is active and
mapped to fifo 4 ra_tid 0x0000 [0,0]
Nov 13 16:29:48 nysa kernel: iwlwifi 0000:02:00.0: Q 9 is active and
mapped to fifo 7 ra_tid 0x0000 [17,17]
Nov 13 16:29:48 nysa kernel: iwlwifi 0000:02:00.0: Q 10 is active and
mapped to fifo 5 ra_tid 0x0000 [0,0]
Nov 13 16:29:48 nysa kernel: iwlwifi 0000:02:00.0: Q 11 is inactive
and mapped to fifo 1 ra_tid 0x0000 [163,163]
Nov 13 16:29:48 nysa kernel: iwlwifi 0000:02:00.0: Q 12 is inactive
and mapped to fifo 3 ra_tid 0x0006 [236,236]
Nov 13 16:29:48 nysa kernel: iwlwifi 0000:02:00.0: Q 13 is inactive
and mapped to fifo 0 ra_tid 0x0000 [0,0]
Nov 13 16:29:48 nysa kernel: iwlwifi 0000:02:00.0: Q 14 is inactive
and mapped to fifo 0 ra_tid 0x0000 [0,0]
Nov 13 16:29:48 nysa kernel: iwlwifi 0000:02:00.0: Q 15 is inactive
and mapped to fifo 0 ra_tid 0x0000 [0,0]
Nov 13 16:29:48 nysa kernel: iwlwifi 0000:02:00.0: Q 16 is inactive
and mapped to fifo 0 ra_tid 0x0000 [0,0]
Nov 13 16:29:48 nysa kernel: iwlwifi 0000:02:00.0: Q 17 is inactive
and mapped to fifo 0 ra_tid 0x0000 [0,0]
Nov 13 16:29:48 nysa kernel: iwlwifi 0000:02:00.0: Q 18 is inactive
and mapped to fifo 0 ra_tid 0x0000 [0,0]
Nov 13 16:29:48 nysa kernel: iwlwifi 0000:02:00.0: Q 19 is inactive
and mapped to fifo 0 ra_tid 0x0000 [0,0]

> In any case - your argumentation above isn't true because every device
> listens for beacons, and if none are received then it should eventually
> disconnect. That should be true even with your hack here.

Should it? I don't see that happening. Where exactly in the code is that check?

> In any case, I'm not really comfortable connecting to an AP that we
> never ever receive beacons from.

Well, we are *already* doing that for every driver, except the ones
that do IEEE80211_HW_NEED_DTIM_BEFORE_ASSOC, which are few.

Cheers.

-- 
Felipe Contreras
