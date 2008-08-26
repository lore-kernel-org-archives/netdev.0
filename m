From: =?ISO-8859-1?Q?D=E2niel?= Fraga <fragabr@gmail.com>
Subject: Re: [PATCH] tcp FRTO: in-order-only "TCP proxy" fragility
 workaround
Date: Tue, 26 Aug 2008 14:18:12 -0300
Message-ID: <20080826141812.589848a0@tux>
References: <20080819213417.45133573@tux>
	<Pine.LNX.4.64.0808201358490.4551@wrl-59.cs.helsinki.fi>
	<20080822183224.2d52f16c@tux>
	<20080822.143709.65615512.davem@davemloft.net>
	<20080823111446.06a350a2@tux>
	<Pine.LNX.4.64.0808231736490.10712@wrl-59.cs.helsinki.fi>
	<20080824163843.33b4f890@tux>
	<Pine.LNX.4.64.0808250948420.27330@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, thomas.jarosch@intra2net.com,
	billfink@mindspring.com, Netdev <netdev@vger.kernel.org>,
	Patrick Hardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org, kadlec@blackhole.kfki.hu
To: "Ilpo =?ISO-8859-1?Q?J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.29]:56265 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753751AbYHZRSW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Aug 2008 13:18:22 -0400
Received: by yx-out-2324.google.com with SMTP id 8so1192498yxm.1
        for <netdev@vger.kernel.org>; Tue, 26 Aug 2008 10:18:21 -0700 (PDT)
In-Reply-To: <Pine.LNX.4.64.0808250948420.27330@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 26 Aug 2008 17:10:46 +0300 (EEST)
"Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi> wrote:

> There is more than one TCP flow in your workload btw (so using=20
> "connection" is a bit more blurry from my/TCP's pov). Some stall and =
never=20
> finish, some get immediately through without any stalling and proceed=
 ok.=20
> So far I've not seen any cases with mixed behavior.

	Interesting.

> It could be userspace related thing.

	Hmmm. I'll try to report this to the dovecot and inn lists.

> It seems that there could well be more than one problem, with symptom=
s=20
> similar enough that they're hard to distinguish without a packet trac=
e.

	Yes, exactly! I think the same.

> Did it solve in this particular case? At least for 995 nothing=20

	Yes. nmap -sS always solves the problem. Very strange. nmap -sS
for me is kind of brute force attempt to restablish the normal
behaviour of the server...=20

	Anyway, I disabled htb and frto and everything is fine for now.
I'll keep investigating this.

> ListenOverflows might explain this (it can't be ListenDrops since it'=
s=20
> equal to ListenOverflows and both get incremented on overflow). Are y=
ou=20
> perhaps short on workers at the userspace server? It would be nice to=
=20

	I use dovecot por mail. I'll post on the dovecot list. If it's
an userspace issue, better.

> capture those mibs often enough (eg., once per 1s with timestamps) du=
ring=20
> the stall to see what actually gets incremented during the event beca=
use=20
> there's currently so much haystack that finding the needle gets impos=
sible=20
> (ListenOverflows 47410) :-). Also, the corresponding tcpdump would be=
=20
> needed to match the events.

	Ok. If I had more useful information, I'll reply.

	Thank you very much!

--=20
