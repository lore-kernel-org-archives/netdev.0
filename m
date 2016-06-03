From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: accept RST if SEQ matches right edge of
 SACK block
Date: Fri, 03 Jun 2016 09:24:54 -0700
Message-ID: <1464971094.5939.192.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1464694717-22548-1-git-send-email-pau.espin@tessares.net>
	 <1464796118.5939.156.camel@edumazet-glaptop3.roam.corp.google.com>
	 <CALCp7mne5OEU1hT-XHoQR33S7tzCRuDMzCu-deXx18QbdBgmYA@mail.gmail.com>
	 <1464966836.5939.189.camel@edumazet-glaptop3.roam.corp.google.com>
	 <CADVnQymK9FfSS26CemJ-powG5WrbBrBr4YcLwO_5iVA6OJ6sGw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Pau Espin <pau.espin@tessares.net>,
	netdev <netdev@vger.kernel.org>,
	Yuchung Cheng <ycheng@google.com>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:33941 "EHLO
	mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752172AbcFCQY5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jun 2016 12:24:57 -0400
Received: by mail-pa0-f68.google.com with SMTP id x1so6316293pav.1
        for <netdev@vger.kernel.org>; Fri, 03 Jun 2016 09:24:57 -0700 (PDT)
In-Reply-To: <CADVnQymK9FfSS26CemJ-powG5WrbBrBr4YcLwO_5iVA6OJ6sGw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-06-03 at 11:45 -0400, Neal Cardwell wrote:
> On Fri, Jun 3, 2016 at 11:13 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > I have no strict opinion on this.
> >
> > It seems to me that checking at most 4 right edges (at least in current
> > linux implementation) is not adding a huge risk, and allows for better
> > interoperability.
> >
> > I vote for no extra sysctl.
> 
> I vote for no extra sysctl as well.
> 
> But I would also vote to tighten up the proposed logic slightly, and
> only check the seq of the incoming RST against the right edge of the
> *right-most* SACK block. That is, the code could loop through the
> tp->selective_acks to find the right-most of the right edges of the
> SACK blocks (the end_seq that has no other end_seq after() it). AFAICT
> it makes sense to expect that a legitimate incoming RST might match
> rcv_nxt, or might match the right-most edge of the right-most SACK.
> But allowing a RST to match a sequence of some SACK in the middle of
> the sequence range would seem to only increase the attack surface for
> RST attacks.

Well, the most recent info would be in [0], no need to iterate, right ?

So only look at the first sack block in the array, even if we have 3 or
4 blocks there.
