From: Michael Tokarev <mjt@tls.msk.ru>
Subject: Re: 3.0: unexpected route cache entry for wrong segment?
Date: Wed, 15 Feb 2012 16:57:55 +0400
Message-ID: <4F3BABD3.5070404@msgid.tls.msk.ru>
References: <4F33FC0E.4020701@msgid.tls.msk.ru>  <1328809519.6099.7.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>  <4F341283.1020904@msgid.tls.msk.ru> <4F3BA0BD.9010501@msgid.tls.msk.ru> <1329310007.2437.16.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from isrv.corpit.ru ([86.62.121.231]:52902 "EHLO isrv.corpit.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757971Ab2BOM55 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Feb 2012 07:57:57 -0500
In-Reply-To: <1329310007.2437.16.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15.02.2012 16:46, Eric Dumazet wrote:
> Le mercredi 15 f=C3=A9vrier 2012 =C3=A0 16:10 +0400, Michael Tokarev =
a =C3=A9crit :
>
>> David, any progress with these?
>>
>> 7cc9150ebe8ec06cafea9f1c10d92ddacf88d8ae "route: fix ICMP redirect v=
alidation"
>> applies correctly to 3.0, but 9cc20b268a5a14f5e57b8ad405a83513ab0d78=
dc
>> "ipv4: fix redirect handling" does not, due to some changes in-betwe=
en,
>> but these should be easy to sort out.  Should I perhaps refresh this
>> patch myself?  It should be doable, I think.
>
> I totally screwed up when I said that, I was mixing things.

Oh ok.  However at least the first patch (fix ICMP redirect validation)
appears to be quite relevant here.  And the second patch is also about
the very same area.

> Can you reproduce this problem with latest 3.0.21 ?

As I described before, it was the only occurence of this issue here.
I wasn't able to reproduce it by sending "bad" ICMP redirects to the
host in question (running 3.0.18).  The host still hasn't been rebooted=
,
it is still running the same 3.0.18, but after the neigh entry expired
there hasn't been any other similar issues.  Or at least not the ones
I actually seen -- it's been one case which looked the same but I haven=
't
seen it really, when I looked it's been gone already since the remote
machine were turned off and the entry has expired (it was from the same
remote segment btw).

Since I still don't understand where that entry (caused by what? stray
ICMP redirect? Something else?) come from in the first place, nor do I
know how to reproduce this, I'm just waiting and watching.

3.0.21 included "net: fix NULL dereferences in check_peer_redir()" patc=
h
(which is somewhat large(ish) - I wonder why it has been rolled into
single patch while in reality it consists of 7 commits; and I wonder
why the final result is different from current version in check_peer_re=
dir()
routine, which I mentioned in my other email in this thread), but that
one does not seem to address this very issue - from a quick view anyway=
=2E

Thank you!

/mjt
