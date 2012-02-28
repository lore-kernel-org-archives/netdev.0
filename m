From: Michael Tokarev <mjt@tls.msk.ru>
Subject: Re: 3.0: unexpected route cache entry for wrong segment?
Date: Tue, 28 Feb 2012 15:38:36 +0400
Message-ID: <4F4CBCBC.8000703@msgid.tls.msk.ru>
References: <4F33FC0E.4020701@msgid.tls.msk.ru>   <1328809519.6099.7.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>   <4F341283.1020904@msgid.tls.msk.ru> <4F3BA0BD.9010501@msgid.tls.msk.ru>  <1329310007.2437.16.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>  <4F3BABD3.5070404@msgid.tls.msk.ru> <1329311013.2437.21.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from isrv.corpit.ru ([86.62.121.231]:36063 "EHLO isrv.corpit.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752867Ab2B2IP1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Feb 2012 03:15:27 -0500
In-Reply-To: <1329311013.2437.21.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15.02.2012 17:03, Eric Dumazet wrote:
> Le mercredi 15 f=C3=A9vrier 2012 =C3=A0 16:57 +0400, Michael Tokarev =
a =C3=A9crit :
>=20
>> 3.0.21 included "net: fix NULL dereferences in check_peer_redir()" p=
atch
>> (which is somewhat large(ish) - I wonder why it has been rolled into
>> single patch while in reality it consists of 7 commits; and I wonder
>> why the final result is different from current version in check_peer=
_redir()
>> routine, which I mentioned in my other email in this thread), but th=
at
>> one does not seem to address this very issue - from a quick view any=
way.
>=20
> That was the tricky part handled by David.
>=20
> We couldnt apply all needed commits without bringing too many things
> from recent kernels to 3.0  (out of stable scope)
>=20
> If you believe a fix is needed, just shout :)

I think the a fix is needed.  I still don't understand where our
unexpected redirects are coming from, but we had two more occurences
of this very issue.  After applying the two patches:

7cc9150ebe8ec06cafea9f1c10d92ddacf88d8ae route: fix ICMP redirect valid=
ation
9cc20b268a5a14f5e57b8ad405a83513ab0d78dc ipv4: fix redirect handling

the issue does not occur anymore.  The system has been running this
kernel for almost 2 weeks now without any issue of this sort.

The first patch applies to 3.0 as it is, the second needs minor
backporting to 3.0.  I already sent the backported version, see
http://patchwork.ozlabs.org/patch/141316/ .

I'm not sure which of the two patches actually helps, but it appears
that both are needed.

Thanks,

/mjt
