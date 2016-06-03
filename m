From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net-next] tcp: accept RST if SEQ matches right edge of
 SACK block
Date: Fri, 3 Jun 2016 11:45:00 -0400
Message-ID: <CADVnQymK9FfSS26CemJ-powG5WrbBrBr4YcLwO_5iVA6OJ6sGw@mail.gmail.com>
References: <1464694717-22548-1-git-send-email-pau.espin@tessares.net>
 <1464796118.5939.156.camel@edumazet-glaptop3.roam.corp.google.com>
 <CALCp7mne5OEU1hT-XHoQR33S7tzCRuDMzCu-deXx18QbdBgmYA@mail.gmail.com> <1464966836.5939.189.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Pau Espin <pau.espin@tessares.net>,
	netdev <netdev@vger.kernel.org>,
	Yuchung Cheng <ycheng@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f43.google.com ([209.85.218.43]:32956 "EHLO
	mail-oi0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751143AbcFCPpD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jun 2016 11:45:03 -0400
Received: by mail-oi0-f43.google.com with SMTP id k23so132919073oih.0
        for <netdev@vger.kernel.org>; Fri, 03 Jun 2016 08:45:02 -0700 (PDT)
In-Reply-To: <1464966836.5939.189.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 3, 2016 at 11:13 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> I have no strict opinion on this.
>
> It seems to me that checking at most 4 right edges (at least in current
> linux implementation) is not adding a huge risk, and allows for better
> interoperability.
>
> I vote for no extra sysctl.

I vote for no extra sysctl as well.

But I would also vote to tighten up the proposed logic slightly, and
only check the seq of the incoming RST against the right edge of the
*right-most* SACK block. That is, the code could loop through the
tp->selective_acks to find the right-most of the right edges of the
SACK blocks (the end_seq that has no other end_seq after() it). AFAICT
it makes sense to expect that a legitimate incoming RST might match
rcv_nxt, or might match the right-most edge of the right-most SACK.
But allowing a RST to match a sequence of some SACK in the middle of
the sequence range would seem to only increase the attack surface for
RST attacks.

neal
