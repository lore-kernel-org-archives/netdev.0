From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net-next] tcp: accept RST if SEQ matches right edge of
 SACK block
Date: Fri, 3 Jun 2016 15:49:17 -0400
Message-ID: <CADVnQykAac+V=tN0k5YXYRrA5sqi0+9FyPO2SppOZQWReELeow@mail.gmail.com>
References: <1464694717-22548-1-git-send-email-pau.espin@tessares.net>
 <1464796118.5939.156.camel@edumazet-glaptop3.roam.corp.google.com>
 <CALCp7mne5OEU1hT-XHoQR33S7tzCRuDMzCu-deXx18QbdBgmYA@mail.gmail.com>
 <1464966836.5939.189.camel@edumazet-glaptop3.roam.corp.google.com>
 <CADVnQymK9FfSS26CemJ-powG5WrbBrBr4YcLwO_5iVA6OJ6sGw@mail.gmail.com>
 <1464971094.5939.192.camel@edumazet-glaptop3.roam.corp.google.com> <CADVnQy=CewFYHhnRHcjLUwLGvc_1_geJrug0OeD0cEVePMwRqQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Pau Espin <pau.espin@tessares.net>,
	netdev <netdev@vger.kernel.org>,
	Yuchung Cheng <ycheng@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f48.google.com ([209.85.218.48]:35146 "EHLO
	mail-oi0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752537AbcFCTtT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jun 2016 15:49:19 -0400
Received: by mail-oi0-f48.google.com with SMTP id w184so142909118oiw.2
        for <netdev@vger.kernel.org>; Fri, 03 Jun 2016 12:49:19 -0700 (PDT)
In-Reply-To: <CADVnQy=CewFYHhnRHcjLUwLGvc_1_geJrug0OeD0cEVePMwRqQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 3, 2016 at 3:44 PM, Neal Cardwell <ncardwell@google.com> wrote:
> On Fri, Jun 3, 2016 at 12:24 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> On Fri, 2016-06-03 at 11:45 -0400, Neal Cardwell wrote:
>>> But I would also vote to tighten up the proposed logic slightly, and
>>> only check the seq of the incoming RST against the right edge of the
>>> *right-most* SACK block. That is, the code could loop through the
>>> tp->selective_acks to find the right-most of the right edges of the
>>> SACK blocks (the end_seq that has no other end_seq after() it). AFAICT
>>> it makes sense to expect that a legitimate incoming RST might match
>>> rcv_nxt, or might match the right-most edge of the right-most SACK.
>>> But allowing a RST to match a sequence of some SACK in the middle of
>>> the sequence range would seem to only increase the attack surface for
>>> RST attacks.
>>
>> Well, the most recent info would be in [0], no need to iterate, right ?
>>
>> So only look at the first sack block in the array, even if we have 3 or
>> 4 blocks there.
>
> Yes, good point. It should only need to check the first SACK block in
> the selective_acks  array.

Well, hmm. The most recent SACK block may not be the right-most one,
if there is reordering or packets are retransmitted. So AFAICT if we
wanted to try hard to just use the right-most SACK block we'd need to
check all the blocks.

But just checking the first SACK block seems like a reasonable
trade-off in terms of simplicity.

I don't feel strongly either way.

neal
